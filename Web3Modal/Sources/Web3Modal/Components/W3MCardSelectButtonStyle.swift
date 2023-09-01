import SwiftUI

struct W3MCardSelectStyle: ButtonStyle {
    enum Variant {
        case wallet
        case network
    }

    @Environment(\.isEnabled) var isEnabled

    let variant: Variant
    let imageUrl: URL

    @State var isLoading = false
    
    @State var isAnimating = false

    init(variant: Variant, imageUrl: URL) {
        self.variant = variant
        self.imageUrl = imageUrl
    }

    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: Spacing.xs) {
            
            
            AsyncImage(url: imageUrl) { image in
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
//                        isAnimating = false
                    }
            } placeholder: {
            
                
                Color.clear.frame(maxWidth: .infinity)
//
//                .transform {
//                    switch variant {
//                    case .network:
//                        $0.clipShape(Hexagon())
//                    case .wallet:
//                        $0.clipShape(RoundedRectangle(cornerRadius: Radius.xs))
//                    }
//                }
            }
            .background(
                GeometryReader { geometry in
                    Rectangle()
                        .fill(
                            LinearGradient(stops: [
                                .init(color: .Background100, location: 0.4),
                                .init(color: .Background200, location: 0.5),
                                .init(color: .Background100, location: 0.6),
                            ], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .onAppear {
                            withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                                isAnimating = true
                            }
                        }
                        .onDisappear {
                            isAnimating = false
                        }
                        .frame(width: geometry.size.width * 3, height: geometry.size.height * 3)
                        .position(.init(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY))
                        .offset(
                            x: isAnimating ? -geometry.size.width * 1 : geometry.size.width * 1,
                            y: isAnimating ? -geometry.size.height * 1 : geometry.size.height * 1
                        )
                        .transform {
                            switch variant {
                            case .network:
                                $0.clipShape(Hexagon())
                            case .wallet:
                                $0.clipShape(RectanglePath())
                                    .clipShape(RoundedRectangle(cornerRadius: Radius.xs))
                            }
                        }
                        .allowsHitTesting(false)
                }
            )
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
                .foregroundColor(configuration.isPressed ? .Blue100 : .Foreground100)
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
        .background(configuration.isPressed ? .Overgray010 : .Overgray005)
        .cornerRadius(Radius.xs)
        .frame(minWidth: 76, maxWidth: 76, minHeight: 96, maxHeight: 96)
    }
}

public struct PreviewView: View {
    
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
            }
        }
        .padding()
        .background(.Overgray002)
    }
}

struct W3MCardSelect_Preview: PreviewProvider {
    static var previews: some View {
        PreviewView()
    }
}

struct Hexagon: Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let sideLength = min(rect.width, rect.height)
        let centerX = rect.midX
        let centerY = rect.midY
        
        path.move(to: CGPoint(x: centerX + sideLength / 2, y: centerY))

        for i in 1 ... 6 {
            let angle = CGFloat(i) * CGFloat.pi / 3
            let x = centerX + sideLength/2 * CGFloat(cos(angle))
            let y = centerY + sideLength/2 * CGFloat(sin(angle))
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.closeSubpath()

        return path
    }
}

struct RectanglePath: Shape {
    
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
