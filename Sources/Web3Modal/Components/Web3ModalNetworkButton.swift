import SwiftUI
import Web3ModalUI

public struct Web3ModalNetworkButton: View {
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
                    leadingImage: {
                        Image.Bold.network
                            .resizable()
                            .frame(width: 14, height: 14)
                            .foregroundColor(.Foreground200)
                            .padding(5)
                            .background(.GrayGlass010)
                            .frame(width: 24, height: 24)
                    }
                )
            )
        }
    }
}

#if DEBUG

public struct NetworkButtonPreviewView: View {
    public init() {}
    
    static let store = { (chain: Chain?) -> Store in
        let store = Store()
        store.balance = 1.23
        store.session = .stub
        store.selectedChain = chain
        return store
    }
    
    public var body: some View {
        VStack {
            Web3ModalNetworkButton(store: NetworkButtonPreviewView.store(nil))
            
            Web3ModalNetworkButton(store: NetworkButtonPreviewView.store(ChainPresets.ethChains[0]))
            
            Web3ModalNetworkButton(store: NetworkButtonPreviewView.store(ChainPresets.ethChains[1]))
            
            Web3ModalNetworkButton(store: NetworkButtonPreviewView.store(ChainPresets.ethChains[0]))
                .disabled(true)
            
            Web3ModalNetworkButton(store: NetworkButtonPreviewView.store(nil))
                .disabled(true)
        }
    }
}

struct NetworkButton_Preview: PreviewProvider {
    static var previews: some View {
        NetworkButtonPreviewView()
    }
}

#endif
