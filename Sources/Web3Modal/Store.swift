import Combine
import SwiftUI
import WalletConnectSign

class Store: ObservableObject {
    
    public static var shared: Store = Store()
    
    @Published var identity: Identity?
    @Published var balance: Double?
    
    @Published var session: Session?
    @Published var uri: WalletConnectURI?
    
    @Published var wallets: [Wallet] = []
    @Published var featuredWallets: [Wallet] = []
    @Published var searchedWallets: [Wallet] = []
    @Published var totalNumberOfWallets: Int = 0
    var walletImages: [String: UIImage] = [:]
    
    @Published var selectedChain: Chain?
    var chainImages: [String: UIImage] = [:]
}
