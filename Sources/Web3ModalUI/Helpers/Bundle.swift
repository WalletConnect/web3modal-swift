import Foundation


#if CocoaPods
public extension Foundation.Bundle {
    private class CocoapodsBundle {}
    
    static var module: Bundle { Bundle.init(for: CocoapodsBundle.self) }
}

#endif
