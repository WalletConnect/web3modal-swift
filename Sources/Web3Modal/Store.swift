import Combine
import SwiftUI
import WalletConnectSign

public class Store: ObservableObject {
    public static var shared: Store = .init()
    
    @Published var identity: Identity?
    @Published var balance: Double?
    
    @Published public var session: Session?
    @Published var uri: WalletConnectURI?
    
    @Published var wallets: [Wallet] = []
    @Published var featuredWallets: [Wallet] = []
    @Published var searchedWallets: [Wallet] = []
    @Published var totalNumberOfWallets: Int = 0
    @Published var walletImages: [String: UIImage] = [:]
    
    @Published public var selectedChain: Chain?
    @Published var chainImages: [String: UIImage] = [:]
}
