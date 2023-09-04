import SnapshotTesting
import SwiftUI
@testable import Web3Modal
import XCTest

final class W3MCardSelectSnapshotTests: XCTestCase {
    
    func test_snapshots() throws {
        let view = W3MCardSelectStylePreviewView()
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
}
