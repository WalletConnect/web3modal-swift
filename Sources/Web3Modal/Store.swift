import Combine
import SwiftUI

class Store: ObservableObject {
    static var shared: Store = .init()
    
    @Published var isModalShown: Bool = false
    
    @Published var identity: Identity?
    @Published var balance: Double?
    
    @Published var connecting: Bool = false
    @Published var account: Account?
    
    // WalletConnect specific
    @Published var session: Session?
    @Published var uri: WalletConnectURI?
    
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

struct Account {
    let address: String
    let networkId: UInt
    let chainNamespace: String
    
    var chainIdentifier: String {
        return "\(chainNamespace):\(networkId)"
    }
}

extension Account {
    
    init?(from session: Session) {
        guard let account = session.accounts.first else {
            return nil
        }
        
        self.init(address: account.address, networkId: 1, chainNamespace: "")
    }
    
    static let stub: Self = .init(
        address: "0x5c8877144d858e41d8c33f5baa7e67a5e0027e37",
        networkId: 56,
        chainNamespace: "eip155"
    )
}
