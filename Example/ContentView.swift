import SwiftUI
import Web3Modal

struct ContentView: View {
    var body: some View {
        NavigationView {
            
            VStack {
                Button("Open W3M") {
                    Web3Modal.present()
                }
                
                NavigationLink("UI Components", destination: ComponentLibraryView())
            }
        }
    }
}
