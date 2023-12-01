import Combine
import SwiftUI

class Store: ObservableObject {
    static var shared: Store = .init()
    
    @Published var isModalShown: Bool = false
    
    @Published var identity: Identity?
    @Published var balance: Double?
    
    @Published var connecting: Bool = false
    @Published var session: Session?
    @Published var uri: WalletConnectURI?
    
    @Published var simplifiedSession: SimplifiedSession?
    
    @Published var wallets: Set<Wallet> = []
    @Published var featuredWallets: [Wallet] = []
    @Published var searchedWallets: [Wallet] = []
    var totalNumberOfWallets: Int = 0
    var currentPage: Int = 0
    var totalPages: Int = .max
    var walletImages: [String: UIImage] = [:]
    var installedWalletIds: [String] = []
    
    var recentWallets: [Wallet] {
        get {
            RecentWalletsStorage.loadRecentWallets()
        }
        set(newValue) {
            RecentWalletsStorage.saveRecentWallets(newValue)
        }
    }
    
    @Published public var selectedChain: Chain?
    @Published var chainImages: [String: UIImage] = [:]
    
    @Published var toast: Toast? = nil
}

struct SimplifiedSession {
    let address: String
    let chainId: String
}
