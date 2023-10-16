import SwiftUI
import Web3Modal
import Web3ModalUI

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Button("Connect Wallet") {
                    Web3Modal.present()
                }
                .buttonStyle(W3MButtonStyle())
                
                Button("Select Network") {
                    Web3Modal.selectChain()
                }
                .buttonStyle(W3MButtonStyle(variant: .accent, leftIcon: Image(systemName: "network")))
                
                Spacer()
                
                NavigationLink("UI Components", destination: ComponentLibraryView())
            }
        }
    }
}
