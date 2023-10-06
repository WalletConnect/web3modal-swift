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
        
        let projectId = Secrets.load().projectID
        
        Networking.configure(
            projectId: projectId,
            socketFactory: WalletConnectSocketClientFactory()
        )

        Web3Modal.configure(
            projectId: projectId,
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
