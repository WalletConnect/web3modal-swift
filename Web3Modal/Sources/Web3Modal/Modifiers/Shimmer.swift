import SwiftUI

struct ShimmerBackground: ViewModifier {
    @State var isAnimating = false

    func body(content: Content) -> some View {
        content
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
                            x: isAnimating ? geometry.size.width : -geometry.size.width,
                            y: isAnimating ? geometry.size.height : -geometry.size.height
                        )

                        .allowsHitTesting(false)
                }
            )
    }
}
