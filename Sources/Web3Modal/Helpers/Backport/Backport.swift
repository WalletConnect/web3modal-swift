import SwiftUI

struct Backport<Wrapped> {
    let wrapped: Wrapped

    init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
    }
}

extension View {
    /// Wraps a SwiftUI `View` that can be extended to provide backport functionality.
    var backport: Backport<Self> { .init(self) }
}
