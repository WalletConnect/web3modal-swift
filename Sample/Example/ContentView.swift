import SwiftUI
import Web3Modal
import Web3ModalUI

struct ContentView: View {
    
    @State var showUIComponets: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Button("Connect Wallet") {
                    Web3Modal.present()
                }
                .buttonStyle(W3MButtonStyle())
                
                Button("Select Network") {
                    Web3Modal.present()
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
        }
    }
}
