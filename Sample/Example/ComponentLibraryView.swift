import SwiftUI
import Web3Modal
import Web3ModalUI

struct ComponentLibraryView: View {
    var body: some View {
        listView
            .navigationTitle("Components")
    }

    var listView: some View {
        Group {
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
                NavigationLink(destination: W3MActionEntryStylePreviewView()) {
                    Text("W3MActionEntry")
                }
                NavigationLink(destination: QRCodeViewPreviewView()) {
                    Text("QRCode")
                }
                NavigationLink(destination: W3MChipButtonStylePreviewView()) {
                    Text("W3MChipButtonStyle")
                }
                NavigationLink(destination: W3MListItemButtonStylePreviewView()) {
                    Text("W3MListItemButtonStyle")
                }
            }
            .listStyle(.plain)
#endif
        }
    }
}
