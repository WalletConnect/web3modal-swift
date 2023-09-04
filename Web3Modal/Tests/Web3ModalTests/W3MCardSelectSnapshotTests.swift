import SnapshotTesting
import SwiftUI
@testable import Web3Modal
import XCTest

final class W3MCardSelectSnapshotTests: XCTestCase {
    
    func test_snapshots() throws {
        let view = W3MCardSelectStylePreviewView().animation(nil)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
        
        assertSnapshot(matching: vc, as: .wait(for: 1, on: .image(traits: .init(userInterfaceStyle: .dark))))
        assertSnapshot(matching: vc, as: .wait(for: 1, on: .image(traits: .init(userInterfaceStyle: .light))))
    }
}
