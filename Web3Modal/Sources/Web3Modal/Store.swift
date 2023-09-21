import Combine
import SwiftUI

class Store: ObservableObject {
    @Published var wallets: [Wallet] = []
    @Published var walletImages: [String: UIImage] = [:]
}
