import Combine
import SwiftUI
import WalletConnectSign
import Web3ModalUI

class Store: ObservableObject {
    static var shared: Store = .init()
    
    @Published var identity: Identity?
    @Published var balance: Double?
    
    @Published var connecting: Bool = false
    @Published var session: Session?
    @Published var uri: WalletConnectURI?
    
    @Published var wallets: [Wallet] = []
    @Published var featuredWallets: [Wallet] = []
    @Published var searchedWallets: [Wallet] = []
    var totalNumberOfWallets: Int = 0
    var walletImages: [String: UIImage] = [:]
    var installedWalletIds: [String] = []
    
    var recentWallets: [Wallet] {
        get {
            RecentWalletsStorage().loadRecentWallets()
        }
        set {
            RecentWalletsStorage().saveRecentWallets(newValue)
        }
    }
    
    @Published public var selectedChain: Chain?
    @Published var chainImages: [String: UIImage] = [:]
    
    @Published var toast: Toast? = nil
}
