import SwiftUI
import Web3Modal

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
                
                Button("Personal sign") {
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
            .onReceive(Web3Modal.instance.socketConnectionStatusPublisher.receive(on: DispatchQueue.main), perform: { status in
                socketConnected = status == .connected
                print("🧦 \(status)")
            })
        }
    }
    
    func requestPersonalSign() {
        Task {
            do {
                guard let address = Web3Modal.instance.getAddress() else { return }
                try await Web3Modal.instance.request(.personal_sign(address: address, message: "Hello there!"))
            } catch {
                print(error)
            }
        }
    }
}
