import SwiftUI

struct W3MCardSelectStyle: ButtonStyle {
    enum Variant {
        case wallet
        case network
    }

    @Environment(\.isEnabled) var isEnabled

    let variant: Variant
    let imageUrl: URL

    var isPressedOverride: Bool?
    var isLoadingOverride: Bool?

    @State var isLoading = false

    init(variant: Variant, imageUrl: URL) {
        self.variant = variant
        self.imageUrl = imageUrl
    }

    #if DEBUG
        init(
            variant: Variant,
            imageUrl: URL,
            isPressedOverride: Bool,
            isLoadingOverride: Bool
        ) {
            self.variant = variant
            self.imageUrl = imageUrl
            self.isPressedOverride = isPressedOverride
            self.isLoadingOverride = isLoadingOverride
        }
    #endif

    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: Spacing.xs) {
            AsyncImage(url: isLoadingOverride != true ? imageUrl : nil) { image in
                image
                    .resizable()
                    .transform {
                        switch variant {
                        case .network:
                            $0.clipShape(Hexagon())
                        case .wallet:
                            $0.clipShape(RoundedRectangle(cornerRadius: Radius.xs))
                        }
                    }
                    .saturation(isEnabled ? 1 : 0)
                    .opacity(isEnabled ? 1 : 0.5)
                    .onAppear {
                        isLoading = false
                    }
            } placeholder: {
                Color.clear.frame(maxWidth: .infinity)
                    .modifier(ShimmerBackground())
                    .transform {
                        switch variant {
                        case .network:
                            $0.clipShape(Hexagon())
                        case .wallet:
                            $0.clipShape(RectanglePath())
                                .clipShape(RoundedRectangle(cornerRadius: Radius.xs))
                        }
                    }
            }
            .frame(width: 56, height: 56)
            .overlay {
                switch variant {
                case .network:
                    Hexagon()
                        .stroke(.Overgray010, lineWidth: 1)
                        .background(Hexagon().fill(.Overgray005).opacity(isLoading ? 1 : 0))
                case .wallet:
                    RoundedRectangle(cornerRadius: Radius.xs)
                        .strokeBorder(.Overgray010, lineWidth: 1)
                        .background(RoundedRectangle(cornerRadius: Radius.xs).fill(.Overgray005).opacity(isLoading ? 1 : 0))
                }
            }
            .onAppear {
                isLoading = true
            }

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
}

private struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let sideLength = min(rect.width, rect.height)
        let centerX = rect.midX
        let centerY = rect.midY

        path.move(to: CGPoint(x: centerX + sideLength / 2, y: centerY))

        for i in 1 ... 6 {
            let angle = CGFloat(i) * CGFloat.pi / 3
            let x = centerX + sideLength / 2 * CGFloat(cos(angle))
            let y = centerY + sideLength / 2 * CGFloat(sin(angle))
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.closeSubpath()

        return path
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
                        imageUrl: URL(string: "https://explorer-api.walletconnect.com/w3m/v1/getWalletImage/7a33d7f1-3d12-4b5c-f3ee-5cd83cb1b500?projectId=c1781fc385454899a2b1385a2b83df3b")!
                    ))

                    Button(action: {}, label: {
                        Text("Rainbow")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .wallet,
                        imageUrl: URL(string: "https://explorer-api.walletconnect.com/w3m/v1/getWalletImage/7a33d7f1-3d12-4b5c-f3ee-5cd83cb1b500?projectId=c1781fc385454899a2b1385a2b83df3b")!
                    ))
                    .disabled(true)

                    Button(action: {}, label: {
                        Text("Rainbow")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .wallet,
                        imageUrl: URL(string: "https://explorer-api.walletconnect.com/w3m/v1/getWalletImage/7a33d7f1-3d12-4b5c-f3ee-5cd83cb1b500?projectId=c1781fc385454899a2b1385a2b83df3b")!,
                        isPressedOverride: true,
                        isLoadingOverride: false
                    ))

                    Button(action: {}, label: {
                        Text("Rainbow")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .wallet,
                        imageUrl: URL(string: "https://explorer-api.walletconnect.com/w3m/v1/getWalletImage/7a33d7f1-3d12-4b5c-f3ee-5cd83cb1b500?projectId=c1781fc385454899a2b1385a2b83df3b")!,
                        isPressedOverride: false,
                        isLoadingOverride: true
                    ))
                }

                HStack {
                    Button(action: {}, label: {
                        Text("Rainbow")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .network,
                        imageUrl: URL(string: "https://explorer-api.walletconnect.com/w3m/v1/getWalletImage/7a33d7f1-3d12-4b5c-f3ee-5cd83cb1b500?projectId=c1781fc385454899a2b1385a2b83df3b")!
                    ))
                    Button(action: {}, label: {
                        Text("Rainbow")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .network,
                        imageUrl: URL(string: "https://explorer-api.walletconnect.com/w3m/v1/getWalletImage/7a33d7f1-3d12-4b5c-f3ee-5cd83cb1b500?projectId=c1781fc385454899a2b1385a2b83df3b")!
                    ))
                    .disabled(true)

                    Button(action: {}, label: {
                        Text("Rainbow")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .network,
                        imageUrl: URL(string: "https://explorer-api.walletconnect.com/w3m/v1/getWalletImage/7a33d7f1-3d12-4b5c-f3ee-5cd83cb1b500?projectId=c1781fc385454899a2b1385a2b83df3b")!,
                        isPressedOverride: true,
                        isLoadingOverride: false
                    ))

                    Button(action: {}, label: {
                        Text("Rainbow")
                    })
                    .buttonStyle(W3MCardSelectStyle(
                        variant: .network,
                        imageUrl: URL(string: "https://explorer-api.walletconnect.com/w3m/v1/getWalletImage/7a33d7f1-3d12-4b5c-f3ee-5cd83cb1b500?projectId=c1781fc385454899a2b1385a2b83df3b")!,
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
        }
    }

#endif
