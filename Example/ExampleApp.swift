import SwiftUI
import Web3Modal
import WalletConnectSign

@main
struct ExampleApp: App {
    init() {
        let metadata = AppMetadata(
            name: "Web3Modal Swift Dapp",
            description: "Web3Modal DApp sample",
            url: "wallet.connect",
            icons: ["https://avatars.githubusercontent.com/u/37784886"]
        )
        
        Networking.configure(
            projectId: "9bfe94c9cbf74aaa0597094ef561f703",
            socketFactory: WalletConnectSocketClientFactory()
        )

        Web3Modal.configure(
            projectId: "9bfe94c9cbf74aaa0597094ef561f703",
            chainId: "eip155:1",
            metadata: metadata
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
