import SwiftUI
import Web3ModalUI

public struct NetworkButton: View {
    @ObservedObject var store: Store
    
    public init() {
        self.store = .shared
    }
    
    init(store: Store = .shared) {
        self.store = store
    }
    
    public var body: some View {
        if let selectedChain = store.selectedChain {
            
            let storedImage = store.chainImages[selectedChain.imageId]
            let chainImage = Image(
                uiImage: storedImage ?? UIImage()
            )
            .resizable()
            .frame(width: 24, height: 24)
            
            Button(selectedChain.chainName) {
                Web3Modal.selectChain()
            }
            .buttonStyle(
                W3MChipButtonStyle(
                    variant: .shade,
                    leadingImage: { chainImage }
                )
            )
        } else {
            Button("Select network") {
                Web3Modal.selectChain()
            }
            .buttonStyle(
                W3MChipButtonStyle(
                    variant: .shade,
                    leadingImage: { Image(systemName: "network") }
                )
            )
        }
    }
}

struct NetworkButton_Preview: PreviewProvider {
    static let store = { (chain: Chain?) -> Store in
        let store = Store()
        store.balance = 1.23
        store.session = .stub
        store.selectedChain = chain
        return store
    }
    
    static var previews: some View {
        VStack {
            NetworkButton(store: NetworkButton_Preview.store(nil))
            
            ConnectButton()
            
            NetworkButton(store: NetworkButton_Preview.store(ChainsPresets.ethChains[0]))
            
            NetworkButton(store: NetworkButton_Preview.store(ChainsPresets.ethChains[1]))
            
            NetworkButton(store: NetworkButton_Preview.store(ChainsPresets.ethChains[0]))
                .disabled(true)
            
            NetworkButton(store: NetworkButton_Preview.store(nil))
                .disabled(true)
        }
    }
}
