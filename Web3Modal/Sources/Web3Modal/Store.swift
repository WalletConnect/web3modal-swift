import Combine
import SwiftUI
import WalletConnectSign

class Store: ObservableObject {
    
    public static var shared: Store = Store()
    
    @Published var session: Session?
    @Published var uri: WalletConnectURI?
    @Published var wallets: [Wallet] = []
    @Published var searchedWallets: [Wallet] = []
    @Published var walletImages: [String: UIImage] = [:]
}
