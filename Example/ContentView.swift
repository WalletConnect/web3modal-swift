import SwiftUI
import Web3Modal

struct ContentView: View {
    var body: some View {
        NavigationView {
            listView
                .navigationTitle("Components")
        }
    }
    
    var listView: some View {
        #if DEBUG
        List {
            NavigationLink(destination: W3MButtonStylePreviewView()) {
                Text("W3MButton")
            }
            NavigationLink(destination: W3MCardSelectStylePreviewView()) {
                Text("W3MCardSelect")
            }
        }
        .listStyle(.plain)
        #endif
    }
}
