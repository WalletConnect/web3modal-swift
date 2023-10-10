import SnapshotTesting
import SwiftUI
@testable import Web3ModalUI
import XCTest

final class W3MChipButtonSnapshotTests: XCTestCase {
    
    func test_snapshots() throws {
        let view = W3MChipButtonStylePreviewView()
        assertSnapshot(matching: view, as: .image(layout: .device(config: .iPhone13), traits: .init(userInterfaceStyle: .dark)))
        assertSnapshot(matching: view, as: .image(layout: .device(config: .iPhone13), traits: .init(userInterfaceStyle: .light)))
    }
}
