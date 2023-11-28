import Foundation


#if CocoaPods
public extension Foundation.Bundle {
    private class CocoapodsBundle {}
    
    static var module: Bundle { Bundle.init(for: CocoapodsBundle.self) }
}

#endif

public extension Foundation.Bundle {
    private class CurrentBundle {}

    /// We override `resource_bundle_accessor.swift` in order to provide correct
    /// path for SwiftUI Preview.
    static var UIModule: Bundle = {
        let moduleBundleNameInPackage = "swift-web3modal_Web3ModalUI"
        let candidates = [
            Bundle.main.resourceURL,
            Bundle(for: CurrentBundle.self).resourceURL,
            Bundle.main.bundleURL,

            /// Provide extra paths to search for resource.
            /// Bundle should be present here when running previews from a different
            /// package (this is the path to `__/Debug-iphonesimulator/__`).
            /// This avoids following error message
            /// `resource_bundle_accessor.swift:27: Fatal error: unable to find bundle named swift-web3modal_Web3ModalUI`
            Bundle(for: CurrentBundle.self).resourceURL?
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent(),

            Bundle(for: CurrentBundle.self).resourceURL?
                .deletingLastPathComponent()
                .deletingLastPathComponent()
        ]

        for candidate in candidates {
            let bundleName = candidate?.appendingPathComponent(moduleBundleNameInPackage + ".bundle")

            if let bundle = bundleName.flatMap(Bundle.init(url:)) {
                print("\(bundle.bundlePath.description)")
                return bundle
            }
        }

        fatalError("unable to find bundle \(moduleBundleNameInPackage.description)")
    }()
}
