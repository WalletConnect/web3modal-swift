import SnapshotTesting
import SwiftUI
@testable import Web3Modal
import XCTest

final class W3MButtonSnapshotTests: XCTestCase {
    
    func test_snapshots() throws {
        let view = W3MButtonStyle.PreviewView()
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
}
