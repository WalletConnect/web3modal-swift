import SwiftUI

struct W3MCardSelectStyle: ButtonStyle {
    enum Variant {
        case wallet
        case network
    }

    @Environment(\.isEnabled) var isEnabled

    let variant: Variant
    var imageUrl: URL?
    var image: Image?

    var isPressedOverride: Bool?
    var isLoadingOverride: Bool?

    @State var isLoading = true

    init(variant: Variant, imageUrl: URL) {
        self.variant = variant
        self.imageUrl = imageUrl
    }

    init(variant: Variant, image: Image) {
        self.variant = variant
        self.image = image
    }

    #if DEBUG
        init(
            variant: Variant,
            imageUrl: URL? = nil,
            image: Image? = nil,
            isPressedOverride: Bool? = nil,
            isLoadingOverride: Bool? = nil
        ) {
            self.variant = variant
            self.imageUrl = imageUrl
            self.image = image
            self.isPressedOverride = isPressedOverride
            self.isLoadingOverride = isLoadingOverride
        }
    #endif

    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: Spacing.xs) {
            imageComponent()
                
            configuration.label
                .font(.tiny500)
                .foregroundColor((isPressedOverride ?? configuration.isPressed) ? .Blue100 : .Foreground100)
                .frame(maxWidth: .infinity)
                .opacity(isLoading ? 0 : 1)
                .overlay {
                    RoundedRectangle(cornerRadius: Radius.xs)
                        .stroke(.Overgray010, lineWidth: 1)
                        .background(RoundedRectangle(cornerRadius: Radius.xs).fill(.Overgray005))
                        .opacity(isLoading ? 1 : 0)
                }
                .padding(.horizontal, Spacing.xs)
        }
        .opacity(isEnabled ? 1 : 0.5)
        .padding(.top, Spacing.xs)
        .padding(.bottom, Spacing.xxs)
        .background((isPressedOverride ?? configuration.isPressed) ? .Overgray010 : .Overgray005)
        .cornerRadius(Radius.xs)
        .frame(minWidth: 76, maxWidth: 76, minHeight: 96, maxHeight: 96)
    }

    @ViewBuilder
    func imageComponent() -> some View {
        VStack {
            if let image {
                image
                    .resizable()
                    .onAppear {
                        isLoading = isLoadingOverride ?? false
                    }
            } else {
                AsyncImage(url: isLoadingOverride != true ? imageUrl : nil) { image in
                    image
                        .resizable()
                } placeholder: {
                    Color.clear.frame(maxWidth: .infinity)
                        .modifier(ShimmerBackground())
                }
            }
        }
        .frame(width: 56, height: 56)
        .saturation(isEnabled ? 1 : 0)
        .opacity(isEnabled ? 1 : 0.5)
        .onAppear {
            isLoading = isLoadingOverride ?? true
        }
        .transform {
            switch variant {
            case .network:
                $0
                    .clipShape(Polygon(count: 6, relativeCornerRadius: 0.25))
            case .wallet:
                $0
                    .clipShape(RectanglePath())
                    .clipShape(RoundedRectangle(cornerRadius: Radius.xs))
            }
        }
        .overlay {
            switch variant {
            case .network:
                Polygon(count: 6, relativeCornerRadius: 0.25)
                    .stroke(.Overgray010, lineWidth: 1)
                    .background(Polygon(count: 6, relativeCornerRadius: 0.25).fill(.Overgray005).opacity(isLoading ? 1 : 0))
            case .wallet:
                RoundedRectangle(cornerRadius: Radius.xs)
                    .strokeBorder(.Overgray010, lineWidth: 1)
                    .background(RoundedRectangle(cornerRadius: Radius.xs).fill(.Overgray005).opacity(isLoading ? 1 : 0))
            }
        }
    }
}

private struct RectanglePath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        path.closeSubpath()

        return path
    }
}

#if DEBUG
    public struct W3MCardSelectStylePreviewView: View {
        public init() {}

        public var body: some View {
            VStack {
                HStack {
                    Button(action: {}, label: {
                        Text("Rainbow")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .wallet,
                        image: Image("MockWalletImage", bundle: .module)
                    ))

                    Button(action: {}, label: {
                        Text("Rainbow")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .wallet,
                        image: Image("MockWalletImage", bundle: .module)
                    ))
                    .disabled(true)

                    Button(action: {}, label: {
                        Text("Rainbow")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .wallet,
                        image: Image("MockWalletImage", bundle: .module),
                        isPressedOverride: true,
                        isLoadingOverride: false
                    ))

                    Button(action: {}, label: {
                        Text("Rainbow")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .wallet,
                        isPressedOverride: false,
                        isLoadingOverride: true
                    ))
                }

                HStack {
                    Button(action: {}, label: {
                        Text("Polygon")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .network,
                        image: Image("MockChainImage", bundle: .module)
                    ))
                    Button(action: {}, label: {
                        Text("Polygon")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .network,
                        image: Image("MockChainImage", bundle: .module)
                    ))
                    .disabled(true)

                    Button(action: {}, label: {
                        Text("Polygon")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .network,
                        image: Image("MockChainImage", bundle: .module),
                        isPressedOverride: true,
                        isLoadingOverride: false
                    ))

                    Button(action: {}, label: {
                        Text("Polygon")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .network,
                        isPressedOverride: false,
                        isLoadingOverride: true
                    ))
                }
            }
            .padding()
            .background(.Overgray002)
        }
    }

    struct W3MCardSelect_Preview: PreviewProvider {
        static var previews: some View {
            W3MCardSelectStylePreviewView()
                .previewLayout(.sizeThatFits)
        }
    }

#endif
