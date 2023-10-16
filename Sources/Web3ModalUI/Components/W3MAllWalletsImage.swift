import SwiftUI

public struct W3MAllWalletsImage: View {
 
    @ScaledMetric var scale: CGFloat = 1
    
    var images: [WalletImage]
    
    public init(images: [WalletImage]) {
        self.images = images
    }

    public var body: some View {
        VStack(spacing: 2 * scale) {
            HStack(spacing: 2 * scale) {
                walletImage(images[safe: 0])
                walletImage(images[safe: 1])
            }
            .padding(.horizontal, 3.5 * scale)

            HStack(spacing: 2 * scale) {
                walletImage(images[safe: 2])
                walletImage(images[safe: 3])
            }
            .padding(.horizontal, 3.5 * scale)
        }
        .padding(.vertical, 3.5 * scale)
        .frame(width: 40 * scale, height: 40 * scale)
        .cornerRadius(Radius.xxxs * scale)
        .overlay {
            RoundedRectangle(cornerRadius: Radius.xxxs)
                .strokeBorder(.Overgray010, lineWidth: 0.5 * scale)
        }
    }

    @ViewBuilder
    func walletImage(_ imageObject: WalletImage?) -> some View {
        
        Group {
            if let image = imageObject?.image {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                W3MAPIAsyncImage(url: URL(string: imageObject?.url ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Image.Wallet
                        .resizable()
                        .scaledToFit()
                        .padding(3 * scale)
                }
            }
        }
        .frame(width: 15 * scale, height: 15 * scale)
        .cornerRadius(Radius.xxxxxs)
        .overlay {
            RoundedRectangle(cornerRadius: Radius.xxxxxs)
                .strokeBorder(.Overgray010, lineWidth: 1)
        }
    }
}

public struct WalletImage {
    let image: Image?
    let url: String?
    let walletName: String?
    
    public init(url: String, walletName: String?) {
        self.image = nil
        self.url = url
        self.walletName = walletName
    }
    
    public init(image: Image, walletName: String?) {
        self.image = image
        self.url = nil
        self.walletName = walletName
    }
}

private extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#if DEBUG
    public struct W3MAllWalletsImageView: View {
        public init() {}

        public var body: some View {
            VStack {
                W3MAllWalletsImage(images: [
                    .init(image: Image("MockWalletImage", bundle: .module), walletName: "Metamask"),
                    .init(image: Image("MockWalletImage", bundle: .module), walletName: "Trust"),
                    .init(image: Image("MockWalletImage", bundle: .module), walletName: "Safe"),
                    .init(image: Image("MockWalletImage", bundle: .module), walletName: "Rainbow"),
                ])
            }
            .padding()
            .background(.Overgray002)
        }
    }

    struct W3MAllWalletsImage_Previews: PreviewProvider {
        static var previews: some View {
            W3MAllWalletsImageView()
                .previewLayout(.sizeThatFits)
        }
    }

#endif
