import Combine
import Sentry
import SwiftUI
import UIKit
import WalletConnectSign
import Web3Modal

#if DEBUG
import Atlantis
#endif


class SocketConnectionManager: ObservableObject {
    @Published var socketConnected: Bool = false
}

@main
class ExampleApp: App {
    private var disposeBag = Set<AnyCancellable>()
    private var socketConnectionManager = SocketConnectionManager()


    @State var alertMessage: String = ""

    required init() {
        #if DEBUG
        Atlantis.start()
        #endif

        let projectId = InputConfig.projectId

        // We're tracking Crash Reports / Issues from the Demo App to keep improving the SDK
        SentrySDK.start { options in
            options.dsn = "https://8b29c857724b94a32ac07ced45452702@o1095249.ingest.sentry.io/4506394479099904"
            options.debug = false
            options.enableTracing = true
        }

        SentrySDK.configureScope { scope in
            scope.setContext(value: ["projectId": projectId], key: "Project")
        }

        let metadata = AppMetadata(
            name: "Web3Modal Swift Dapp",
            description: "Web3Modal DApp sample",
            url: "www.web3modal.com",
            icons: ["https://avatars.githubusercontent.com/u/37784886"],
            redirect: .init(native: "w3mdapp://", universal: nil)
        )

        Networking.configure(
            groupIdentifier: "group.com.walletconnect.web3modal",
            projectId: projectId,
            socketFactory: DefaultSocketFactory()
        )

        Web3Modal.configure(
            projectId: projectId,
            metadata: metadata,
            crypto: DefaultCryptoProvider(),
            customWallets: [
                .init(
                     id: "swift-sample",
                     name: "Swift Sample Wallet",
                     homepage: "https://walletconnect.com/",
                     imageUrl: "https://avatars.githubusercontent.com/u/37784886?s=200&v=4",
                     order: 1,
                     mobileLink: "walletapp://"
                 )
            ]
        ) { error in
            SentrySDK.capture(error: error)
            
            print(error)
        }
        setup()

    }

    func setup() {
        Web3Modal.instance.socketConnectionStatusPublisher.receive(on: DispatchQueue.main).sink { [unowned self] status in
            print("Socket connection status: \(status)")
            self.socketConnectionManager.socketConnected = (status == .connected)

        }.store(in: &disposeBag)
        Web3Modal.instance.logger.setLogging(level: .debug)
    }

    var body: some Scene {
        WindowGroup { [unowned self] in
            ContentView()
                .environmentObject(socketConnectionManager)
                .onOpenURL { url in
                    Web3Modal.instance.handleDeeplink(url)
                }
                .alert(
                    "Response",
                    isPresented: .init(
                        get: { !self.alertMessage.isEmpty },
                        set: { _ in self.alertMessage = "" }
                    )
                ) {
                    Button("Dismiss", role: .cancel) {}
                } message: {
                    Text(alertMessage)
                }
                .onReceive(Web3Modal.instance.sessionResponsePublisher, perform: { response in
                    switch response.result {
                    case let .response(value):
                        self.alertMessage = "Session response: \(value.stringRepresentation)"
                    case let .error(error):
                        self.alertMessage = "Session error: \(error)"
                    }
                })
        }
    }
}
