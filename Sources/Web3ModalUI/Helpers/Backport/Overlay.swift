import SwiftUI

public extension Backport where Wrapped: View {
    func overlay<Content: View>(alignment: Alignment = .center, @ViewBuilder _ content: () -> Content) -> some View {
        self.wrapped.overlay(content(), alignment: alignment)
    }
}
