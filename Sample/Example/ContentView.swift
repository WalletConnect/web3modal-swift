import SwiftUI
import Web3Modal

struct ContentView: View {
    @State var showUIComponents: Bool = false
    @State var socketConnected: Bool = false
    
    @State var isLoading: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Web3ModalButton()
                
                Web3ModalNetworkButton()
                
                Spacer()
                
                Button(isLoading ? "Loading" : "Personal sign") {
                    requestPersonalSign()
                    Web3Modal.instance.launchCurrentWallet()
                }
                .buttonStyle(W3MButtonStyle())
                
                
                Button(isLoading ? "Loading" : "Send transaction") {
                    requestSendTransaction()
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
        
        isLoading = true
        
        Task {
            do {
                try await Web3Modal.instance.personal_sign(message: "Hello there!")
                isLoading = false
            } catch {
                print(error)
            }
        }
    }
    
    func requestSendTransaction() {
        isLoading = true
        
        Task {
            do {
                guard let address = Web3Modal.instance.getAddress() else { return }
                guard let chain = Web3Modal.instance.getSelectedChain() else { return }
                
                try await Web3Modal.instance.request(W3MJSONRPC.eth_sendTransaction(
                    from: address,
                    to: "0xED2671343DAd40fE7feA57d8B0DE1369F9Dba956",
                    value: "0x110d9316ec000",
                    data: "0xefef39a10000000000000000000000000000000000000000000000000000000000000001",
                    nonce: nil,
                    gas: "0x4d2",
                    gasPrice: nil,
                    maxFeePerGas: nil,
                    maxPriorityFeePerGas: nil,
                    gasLimit: nil,
                    chainId: chain.chainReference
                ))
                isLoading = false
            } catch {
                print(error)
            }
        }
    }
}
