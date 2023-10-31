import SwiftUI
import Web3Modal
import Web3ModalUI

struct ContentView: View {
    
    @State var showUIComponents: Bool = false
    @State var socketConnected: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Web3Button()
                
                NetworkButton()
                
                Spacer()
                    
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
                }
                
            , alignment: .top
            )
            .onReceive(Web3Modal.instance.socketConnectionStatusPublisher.receive(on: RunLoop.main), perform: { status in
                socketConnected = status == .connected
            })
        }
    }
}
