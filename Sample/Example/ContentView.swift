import SwiftUI
import Web3Modal
import Web3ModalUI

struct ContentView: View {
    
    @State var showUIComponets: Bool = false
    
    @State var id: UUID = UUID()
    
    @State var socketConnected: Bool = false
    
    var addressFormatted: String? {
        guard let address = Store.shared.session?.accounts.first?.address else {
            return nil
        }
        
        return String(address.prefix(4)) + "..." + String(address.suffix(4))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Button(addressFormatted ?? "Connect Wallet") {
                    Web3Modal.present()
                }
                .buttonStyle(W3MButtonStyle())
                
                let chainName = Store.shared.selectedChain?.chainName
                
                Button(chainName ?? "Select Network") {
                    Web3Modal.selectChain()
                }
                .buttonStyle(W3MButtonStyle(variant: .accent, leftIcon: Image(systemName: "network")))
                
                Spacer()
                    
                NavigationLink(destination: ComponentLibraryView(), isActive: $showUIComponets) {
                    Button("UI components") {
                        showUIComponets = true
                    }
                    .buttonStyle(W3MButtonStyle())
                }
            }
            .id(id)
            .overlay(
                HStack {
                    Circle()
                        .fill(socketConnected ? Color.Success100 : Color.Error100)
                        .frame(width: 10, height: 10)
                    
                    
                    Text("Socket \(socketConnected ? "Connected" : "Disconnected")")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(socketConnected ? Color.Success100 : Color.Error100)
                }
                
            , alignment: .top
            )
            .onReceive(Web3Modal.instance.socketConnectionStatusPublisher.receive(on: RunLoop.main), perform: { status in
                socketConnected = status == .connected
            })
            .onReceive(Store.shared.objectWillChange, perform: { _ in
                id = UUID()
            })
        }
    }
}
