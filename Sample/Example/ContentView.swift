import SwiftUI
import Web3Modal
import Web3ModalUI

struct ContentView: View {
    
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
                
                VStack(spacing: 10) {
                    Group {
                        Text("large500").scaledFont(size: 20, weight: .black)
                        Text("large600").font(.large600)
                        Text("large700").font(.large700)
                    }
                    Group {
                        Text("title500").font(.title500)
                        Text("title600").font(.title600)
                        Text("title700").font(.title700)
                    }
                    Group {
                        Text("paragraph500").font(.paragraph500)
                        Text("paragraph600").font(.paragraph600)
                        Text("paragraph700").font(.paragraph700)
                    }
                    Group {
                        Text("micro600").font(.micro600)
                        Text("micro700").font(.micro700)
                    }
                    Group {
                        Text("small500").font(.small500)
                        Text("small600").font(.small600)
                    }
                    Group {
                        Text("tiny500").font(.tiny500)
                        Text("tiny600").font(.tiny600)
                    }
                }
            }
                
            Spacer()
                
            NavigationLink("UI Components", destination: ComponentLibraryView())
        }
    }
}
