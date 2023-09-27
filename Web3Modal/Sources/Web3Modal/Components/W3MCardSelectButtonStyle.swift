import SwiftUI

struct W3MCardSelectStyle<ImageContent: View>: ButtonStyle {
    enum Variant {
        case wallet
        case network
    }

    @Environment(\.isEnabled) var isEnabled

    let variant: Variant

    var imageContent: () -> ImageContent
    var isPressedOverride: Bool?

    @Binding var isLoading: Bool

    init(
        variant: Variant,
        @ViewBuilder imageContent: @escaping () -> ImageContent,
        isLoading: Binding<Bool>
    ) {
        self.variant = variant
        self.imageContent = imageContent
        self._isLoading = isLoading
    }

    #if DEBUG
        init(
            variant: Variant,
            @ViewBuilder imageContent: @escaping () -> ImageContent,
            isPressedOverride: Bool? = nil,
            isLoading: Binding<Bool>
        ) {
            self.variant = variant
            self.imageContent = imageContent
            self.isPressedOverride = isPressedOverride
            self._isLoading = isLoading
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
        imageContent()
            .frame(width: 56, height: 56)
            .saturation(isEnabled ? 1 : 0)
            .opacity(isEnabled ? 1 : 0.5)
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
                        imageContent: { Image("MockWalletImage", bundle: .module).resizable() },
                        isLoading: .constant(false)
                    ))

                    Button(action: {}, label: {
                        Text("Rainbow")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .wallet,
                        imageContent: { Image("MockWalletImage", bundle: .module).resizable() },
                        isLoading: .constant(false)
                    ))
                    .disabled(true)

                    Button(action: {}, label: {
                        Text("Rainbow")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .wallet,
                        imageContent: { Image("MockWalletImage", bundle: .module).resizable() },
                        isPressedOverride: true,
                        isLoading: .constant(false)
                    ))

                    Button(action: {}, label: {
                        Text("Rainbow")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .wallet,
                        imageContent: { Color.Overgray005 },
                        isPressedOverride: false,
                        isLoading: .constant(true)
                    ))
                }

                HStack {
                    Button(action: {}, label: {
                        Text("Polygon")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .network,
                        imageContent: { Image("MockChainImage", bundle: .module).resizable() },
                        isLoading: .constant(false)
                    ))
                    Button(action: {}, label: {
                        Text("Polygon")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .network,
                        imageContent: { Image("MockChainImage", bundle: .module).resizable() },
                        isLoading: .constant(false)
                    ))
                    .disabled(true)

                    Button(action: {}, label: {
                        Text("Polygon")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .network,
                        imageContent: { Image("MockChainImage", bundle: .module).resizable() },
                        isPressedOverride: true,
                        isLoading: .constant(false)
                    ))

                    Button(action: {}, label: {
                        Text("Polygon")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .network,
                        imageContent: { Color.Overgray005 },
                        isPressedOverride: false,
                        isLoading: .constant(true)
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
