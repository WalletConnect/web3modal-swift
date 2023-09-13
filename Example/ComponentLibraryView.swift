import SwiftUI
import Web3Modal

struct ComponentLibraryView: View {
    var body: some View {
        listView
            .navigationTitle("Components")
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
            NavigationLink(destination: W3MTagPreviewView()) {
                Text("W3MTag")
            }
            NavigationLink(destination: W3MListSelectStylePreviewView()) {
                Text("W3MListSelect")
            }
        }
        .listStyle(.plain)
        #endif
    }
}