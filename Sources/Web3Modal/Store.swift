import Combine
import SwiftUI

enum ConnectionProviderType {
    case wc
    case cb
}

class Store: ObservableObject {
    static var shared: Store = .init()
    
    @Published var isModalShown: Bool = false
    
    @Published var identity: Identity?
    @Published var balance: Double?
    
    @Published var connectedWith: ConnectionProviderType?
    @Published var connecting: Bool = false
    @Published var account: Account? {
        didSet {
            let matchingChain = ChainPresets.ethChains.first(where: {
                $0.chainNamespace == account?.chain.namespace && $0.chainReference == account?.chain.reference
            })
            
            Store.shared.selectedChain = matchingChain
        }
    }
    
    // WalletConnect specific
    @Published var session: Session? {
        didSet {
            if let blockchain = session?.accounts.first?.blockchain {
                let matchingChain = ChainPresets.ethChains.first(where: {
                    $0.chainNamespace == blockchain.namespace && $0.chainReference == blockchain.reference
                })
                
                Store.shared.selectedChain = matchingChain
            }
        }
    }
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
    let chain: Blockchain
}

extension Account {
    
    init?(from session: Session) {
        guard let account = session.accounts.first else {
            return nil
        }
        
        self.init(address: account.address, chain: account.blockchain)
    }
    
    static let stub: Self = .init(
        address: "0x5c8877144d858e41d8c33f5baa7e67a5e0027e37",
        chain: Blockchain(namespace: "eip155", reference: "56")!
    )
}
