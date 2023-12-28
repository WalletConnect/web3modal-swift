import Sentry
import SwiftUI

import WalletConnectSign
import Web3Modal

#if DEBUG
import Atlantis
#endif

@main
struct ExampleApp: App {
    init() {
        #if DEBUG
        Atlantis.start()
        #endif

        let projectId = Secrets.load().projectID
        
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
            url: "wallet.connect",
            icons: ["https://avatars.githubusercontent.com/u/37784886"],
            redirect: .init(native: "w3mdapp://", universal: nil)
        )

        Networking.configure(
            projectId: projectId,
            socketFactory: WalletConnectSocketClientFactory()
        )

        Web3Modal.configure(
            projectId: projectId,
            metadata: metadata
        ) { error in
            SentrySDK.capture(error: error)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
