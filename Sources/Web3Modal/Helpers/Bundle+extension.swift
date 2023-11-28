import Foundation

#if CocoaPods
public extension Foundation.Bundle {
    private class CocoapodsBundle {}

    static var coreModule: Bundle { Bundle(for: CocoapodsBundle.self) }
}
#else
public extension Foundation.Bundle {
    static var coreModule: Bundle { Bundle.module }
}
#endif
