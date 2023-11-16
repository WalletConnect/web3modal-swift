import SwiftUI
import Web3Modal
import Web3ModalUI
import WalletConnectUtils

struct ContentView: View {
    @State var showUIComponents: Bool = false
    @State var socketConnected: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Web3ModalButton()
                
                Web3ModalNetworkButton()
                
                Spacer()
                
                Button("Sign transaction") {
                    requestPersonalSign()
                    Web3Modal.instance.launchCurrentWallet()
                }
                .buttonStyle(W3MButtonStyle())
                    
                NavigationLink(destination: ComponentLibraryView(), isActive: $showUIComponents) {
                    Button("UI components") {
                        showUIComponents = true
                    }
                    .buttonStyle(W3MButtonStyle())
                }
            }
            .overlay(
                HStack {
                    Circle()
                        .fill(socketConnected ? Color.Success100 : Color.Error100)
                        .frame(width: 10, height: 10)
                    
                    Text("Socket \(socketConnected ? "Connected" : "Disconnected")")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(socketConnected ? Color.Success100 : Color.Error100)
                },
                alignment: .top
            )
            .onReceive(Web3Modal.instance.socketConnectionStatusPublisher.receive(on: RunLoop.main), perform: { status in
                socketConnected = status == .connected
            })
        }
    }
    
    func requestPersonalSign() {
        guard
            let session = Web3Modal.instance.getSessions().first,
            let chain = Web3Modal.instance.getSelectedChain(),
            let blockchain = Blockchain(namespace: chain.chainNamespace, reference: chain.chainReference)
        else { return }
        
        Task {
            try await Web3Modal.instance.request(
                params: .init(
                    topic: session.topic,
                    method: "personal_sign",
                    params: AnyCodable(any: [session.accounts.first?.address ?? "", "Hello world!"]),
                    chainId: blockchain
                )
            )
        }
    }
}
