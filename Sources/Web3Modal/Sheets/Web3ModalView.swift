import SwiftUI

struct Web3ModalView: View {
    @ObservedObject var viewModel: Web3ModalViewModel

    @EnvironmentObject var signInteractor: SignInteractor
    @EnvironmentObject var store: Store
    @EnvironmentObject var router: Router

    var body: some View {
        VStack(spacing: 0) {
            modalHeader()
            routes()
        }
        .background(Color.Background125)
        .cornerRadius(30, corners: [.topLeft, .topRight])
    }
    
    @ViewBuilder
    private func routes() -> some View {
        switch router.currentRoute as? Router.ConnectingSubpage {
        case .none:
            EmptyView()
        case .connectWallet:
            ConnectWalletView()
        case .otpInput:
            EnterOTPView()
        case .allWallets:
            if #available(iOS 14.0, *) {
                AllWalletsView()
            } else {
                Text("Please upgrade to iOS 14 to use this feature")
            }
        case .qr:
            ConnectWithQRCode()
        case .whatIsAWallet:
            WhatIsWalletView()
        case let .walletDetail(wallet):
            WalletDetailView(
                viewModel: .init(
                    wallet: wallet,
                    router: router,
                    signInteractor: signInteractor,
                    store: store
                )
            )
        case .getWallet:
            GetAWalletView()
        case let .otpResult(success):
            Text("verify OTP \(success ? "success" : "failed")")
        case .some(.verifyDevice):
            Text("Please verify your device first to continue, by going to the magic link sent to your email.")
        case .some(.magicWebview):
            Text("Magic webview here 🧚")
        }
    }
    
    private func modalHeader() -> some View {
        HStack(spacing: 0) {
            switch router.currentRoute as? Router.ConnectingSubpage {
            case .none:
                EmptyView()
            case .connectWallet:
                helpButton()
            default:
                backButton()
            }
            
            Spacer()
            
            (router.currentRoute as? Router.ConnectingSubpage)?.title.map { title in
                Text(title)
                    .font(.paragraph700)
            }
            
            Spacer()
            
            closeButton()
        }
        .padding()
        .frame(height: 64)
        .frame(maxWidth: .infinity)
        .foregroundColor(.Foreground100)
        .overlay(
            RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
                .stroke(Color.GrayGlass005, lineWidth: 1)
        )
        .cornerRadius(30, corners: [.topLeft, .topRight])
    }
    
    private func helpButton() -> some View {
        Button(action: {
            router.setRoute(Router.ConnectingSubpage.whatIsAWallet)
        }, label: {
            Image.Medium.questionMarkCircle
        })
    }
    
    private func backButton() -> some View {
        Button {
            router.goBack()
        } label: {
            Image.Medium.chevronLeft
        }
    }
    
    private func closeButton() -> some View {
        Button {
            withAnimation {
                store.isModalShown = false
            }
        } label: {
            Image.Medium.xMark
        }
    }
}

extension Router.ConnectingSubpage {
    var title: String? {
        switch self {
        case .connectWallet:
            return "Connect wallet"
        case .qr:
            return "WalletConnect"
        case .otpInput, .otpResult:
            return "Confirm Email"
        case .allWallets:
            return "All wallets"
        case .whatIsAWallet:
            return "What is a wallet?"
        case let .walletDetail(wallet):
            return "\(wallet.name)"
        case .getWallet:
            return "Get wallet"
        case .verifyDevice:
            return "Verify Device"
        case .magicWebview:
            return "Magic webview TBD"
        }
    }
}

struct Web3ModalView_Previews: PreviewProvider {
    class MockWebSocketConnecting: WebSocketConnecting {
        init() {
            self.onConnect = nil
            self.onDisconnect = nil
            self.onText = nil
            self.request = URLRequest(url: URL(string: "www.google.com")!)
        }
        
        var isConnected: Bool { false }
        var onConnect: (() -> Void)?
        var onDisconnect: ((Error?) -> Void)?
        var onText: ((String) -> Void)?
        var request: URLRequest
        func connect() {}
        func disconnect() {}
        func write(string: String, completion: (() -> Void)?) {}
    }
    
    struct MockSockFactory: WebSocketFactory {
        public init() {}
        
        public func create(with url: URL) -> WebSocketConnecting {
            return MockWebSocketConnecting()
        }
    }
    
    static let viewModel: Web3ModalViewModel = {
        let projectId = Bundle.main.object(forInfoDictionaryKey: "PROJECT_ID") as? String ?? ""

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
            socketFactory: MockSockFactory()
        )

        Web3Modal.configure(
            projectId: projectId,
            metadata: metadata
        )
        
        return .init(
            router: router,
            store: store,
            w3mApiInteractor: W3MAPIInteractor(store: store),
            signInteractor: SignInteractor(store: store),
            blockchainApiInteractor: BlockchainAPIInteractor(store: store)
        )
    }()
    
    static let router = {
        let router = Router()
        router.setRoute(Router.ConnectingSubpage.otpInput)
        return router
    }()
    
    static let store = {
        let store = Store()
        store.email = "radek@walletconnect.com"
        return store
    }()
    
    static var previews: some View {
        Web3ModalView(viewModel: viewModel)
            .environmentObject(router)
            .environmentObject(store)
            .previewLayout(.sizeThatFits)
    }
}
