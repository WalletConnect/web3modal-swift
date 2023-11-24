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
            Button(selectedChain.chainName) {
                Web3Modal.selectChain()
            }
            .buttonStyle(
                W3MChipButtonStyle(
                    variant: .shade,
                    leadingImage: {
                        if let storedImage = store.chainImages[selectedChain.imageId] {
                            Image(uiImage: storedImage)
                                .resizable()
                                .frame(width: 24, height: 24)
                        } else {
                            Image.Bold.network
                                .resizable()
                                .foregroundColor(.Foreground200)
                                .padding(Spacing.xxxs)
                                .background(.GrayGlass010)
                                .frame(width: 24, height: 24)
                        }
                    }
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
                            .foregroundColor(.Foreground200)
                            .padding(Spacing.xxxs)
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
        store.chainImages[ChainPresets.ethChains[0].imageId] = UIImage(
            named: "MockWalletImage", in: .UIModule, compatibleWith: nil
        )
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
