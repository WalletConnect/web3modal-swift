import SwiftUI
import Web3ModalUI

public struct ConnectButton: View {
    
    @ObservedObject var store: Store
    
    public init() {
        self.store = .shared
    }
    
    init(store: Store = .shared) {
        self.store = store
    }
    
    public var body: some View {
        Button {
            Web3Modal.present()
        } label: {
            if store.connecting {
                CircleProgressView(color: .white, lineWidth: 2, isAnimating: .constant(true))
                    .frame(width: 20, height: 20)
            } else {
                Text("Connect Wallet")
            }
        }
        .buttonStyle(W3MButtonStyle())
    }
}


struct ConnectButton_Preview: PreviewProvider {
    
    static let store = { () -> Store in
        let store = Store()
        store.balance = 1.23
        store.session = .stub
        return store
    }()
    
    static var previews: some View {
        VStack {
            ConnectButton()
            
            ConnectButton()
                .disabled(true)
        }
        .environmentObject(ConnectButton_Preview.store)
    }
}
