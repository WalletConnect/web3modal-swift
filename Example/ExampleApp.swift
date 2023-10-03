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

        Web3Modal.configure(
            projectId: "foo",
            metadata: metadata
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
