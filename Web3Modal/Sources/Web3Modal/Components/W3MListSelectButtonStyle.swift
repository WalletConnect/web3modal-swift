import SwiftUI

struct W3MListSelectStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    @ScaledMetric var scale: CGFloat = 1

    var imageUrl: URL?
    var image: Image?
    var tag: W3MTag?
    var allWalletsImage: W3MAllWalletsImage?

    var isPressedOverride: Bool?

    init(allWalletsImage: W3MAllWalletsImage, tag: W3MTag? = nil) {
        self.allWalletsImage = allWalletsImage
        self.tag = tag
    }

    init(imageUrl: URL, tag: W3MTag? = nil) {
        self.imageUrl = imageUrl
        self.tag = tag
    }

    init(image: Image, tag: W3MTag? = nil) {
        self.image = image
        self.tag = tag
    }

    #if DEBUG
        init(
            imageUrl: URL? = nil,
            image: Image? = nil,
            tag: W3MTag? = nil,
            isPressedOverride: Bool? = nil
        ) {
            self.imageUrl = imageUrl
            self.image = image
            self.tag = tag
            self.isPressedOverride = isPressedOverride
        }
    #endif

    func makeBody(configuration: Configuration) -> some View {
        let layoutBreakCondition = dynamicTypeSize >= .accessibility2
        
        AdaptiveStack(
            condition: layoutBreakCondition,
            horizontalAlignment: .center,
            spacing: Spacing.xs * scale
        ) {
            Group {
                imageComponent()
                    .scaledToFill()
                    .layoutPriority(3)
                
                configuration.label
                    .lineLimit(1)
                    .scaledToFill()
                    .font(.paragraph500)
                    .foregroundColor(.Foreground100)
                    .layoutPriority(5)
                
                if !layoutBreakCondition {
                    Spacer()
                }
                
                if let tag {
                    tag
                        .saturation(isEnabled ? 1 : 0)
                        .layoutPriority(3)
                } else if !layoutBreakCondition {
                    Spacer()
                        .layoutPriority(3)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .opacity(isEnabled ? 1 : 0.5)
        .padding(.vertical, Spacing.xs * scale)
        .padding(.leading, Spacing.xs * scale)
        .padding(.trailing, Spacing.xs * scale)
        .background((isPressedOverride ?? configuration.isPressed) ? .Overgray010 : .Overgray005)
        .cornerRadius(Radius.xs * scale)
    }

    @ViewBuilder
    func imageComponent() -> some View {
        VStack {
            if let image {
                image
                    .resizable()
            } else if let allWalletsImage {
                allWalletsImage
            } else {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                } placeholder: {
                    Image.Wallet
                }
            }
        }
        .frame(maxWidth: 40 * scale, maxHeight: 40 * scale)
        .aspectRatio(contentMode: .fit)
        .saturation(isEnabled ? 1 : 0)
        .opacity(isEnabled ? 1 : 0.5)
        .background(.Overgray005)
        .cornerRadius(Radius.xxxs * scale)
        .overlay {
            RoundedRectangle(cornerRadius: Radius.xxxs * scale)
                .strokeBorder(.Overgray010, lineWidth: 1 * scale)
        }
    }
}

#if DEBUG
    public struct W3MListSelectStylePreviewView: View {
        public init() {}

        public var body: some View {
            ScrollView {
                VStack {
                    Button(action: {}, label: {
                        Text("Rainbow")
                    })
                    .buttonStyle(W3MListSelectStyle(
                        image: Image("MockWalletImage", bundle: .module),
                        tag: W3MTag(title: "QR Code", variant: .main)
                    ))
                    
                    Button(action: {}, label: {
                        Text("Rainbow")
                    })
                    .buttonStyle(W3MListSelectStyle(
                        tag: W3MTag(title: "Installed", variant: .success),
                        isPressedOverride: false
                    ))
                    
                    Button(action: {}, label: {
                        Text("Rainbow")
                    })
                    .buttonStyle(W3MListSelectStyle(
                        image: Image("MockWalletImage", bundle: .module)
                    ))
                    
                    Button(action: {}, label: {
                        Text("All wallets")
                    })
                    .buttonStyle(W3MListSelectStyle(
                        allWalletsImage: W3MAllWalletsImage(images: [
                            .init(image: Image("MockWalletImage", bundle: .module), walletName: "Metamask"),
                            .init(image: Image("MockWalletImage", bundle: .module), walletName: "Trust"),
                            .init(image: Image("MockWalletImage", bundle: .module), walletName: "Safe"),
                            .init(image: Image("MockWalletImage", bundle: .module), walletName: "Rainbow"),
                        ])
                    ))
                    
                    Button(action: {}, label: {
                        Text("Rainbow")
                    })
                    .buttonStyle(W3MListSelectStyle(
                        image: Image("MockWalletImage", bundle: .module),
                        tag: W3MTag(title: "QR Code", variant: .main)
                    ))
                    .disabled(true)
                }
                .padding()
//                .background(.Overgray002)
            }
        }
    }

    struct W3MListSelect_Preview: PreviewProvider {
        static var previews: some View {
            W3MListSelectStylePreviewView()
                .previewLayout(.sizeThatFits)
        }
    }

#endif

