import SwiftUI

public struct Web3ModalButton: View {
    @ObservedObject var store: Store
    
    public init() {
        self.store = .shared
    }
    
    init(store: Store = .shared) {
        self.store = store
    }
    
    public var body: some View {
        Group {
            if let _ = store.session {
                AccountButton()
            } else {
                ConnectButton()
            }
        }
    }
}

struct Web3Button_Preview: PreviewProvider {
    static let store = { () -> Store in
        let store = Store()
        store.balance = 1.23
        store.session = .stub
        return store
    }()
    
    static var previews: some View {
        VStack {
            Web3ModalButton(store: Web3Button_Preview.store)
            
            Web3ModalButton(store: Web3Button_Preview.store)
                .disabled(true)
        }
    }
}
