import CoinbaseWalletSDK
import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// Web3Modal instance wrapper
///
/// ```Swift
/// let metadata = AppMetadata(
///     name: "Swift dapp",
///     description: "dapp",
///     url: "dapp.wallet.connect",
///     icons:  ["https://my_icon.com/1"]
/// )
/// Web3Modal.configure(projectId: PROJECT_ID, metadata: metadata)
/// Web3Modal.instance.getSessions()
/// ```
public class Web3Modal {
    /// Web3Modalt client instance
    public static var instance: Web3ModalClient = {
        guard let config = Web3Modal.config else {
            fatalError("Error - you must call Web3Modal.configure(_:) before accessing the shared instance.")
        }
        let client = Web3ModalClient(
            logger: ConsoleLogger(prefix: "📜", loggingLevel: .off),
            signClient: Sign.instance,
            pairingClient: Pair.instance as! (PairingClientProtocol & PairingInteracting & PairingRegisterer),
            store: .shared,
            analyticsService: .shared
        )
        
        let store = Store.shared
        
        if let session = client.getSessions().first {
            store.session = session
            store.connectedWith = .wc
            store.account = .init(from: session)
        } else if CoinbaseWalletSDK.shared.isConnected() {
            
            let storedAccount = AccountStorage.read()
            store.connectedWith = .cb
            store.account = storedAccount
        } else {
            AccountStorage.clear()
        }
        
        return client
    }()
    
    struct Config {
        static let sdkVersion: String = {
            guard
                let fileURL = Bundle.coreModule.url(forResource: "PackageConfig", withExtension: "json"),
                let data = try? Data(contentsOf: fileURL),
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let version = jsonObject["version"] as? String
            else {
                return "undefined"
            }
                    
            return "swift-\(version)"
        }()

        static let sdkType = "w3m"
        
        let projectId: String
        var metadata: AppMetadata
        var sessionParams: SessionParams
        
        let includeWebWallets: Bool
        let recommendedWalletIds: [String]
        let excludedWalletIds: [String]
        let customWallets: [Wallet]
        let coinbaseEnabled: Bool

        let onError: (Error) -> Void
    }
    
    private(set) static var config: Config!
    
    private(set) static var viewModel: Web3ModalViewModel!

    private init() {}

    /// Wallet instance wallet config method.
    /// - Parameters:
    ///   - metadata: App metadata
    public static func configure(
        projectId: String,
        metadata: AppMetadata,
        sessionParams: SessionParams = .default,
        includeWebWallets: Bool = true,
        recommendedWalletIds: [String] = [],
        excludedWalletIds: [String] = [],
        customWallets: [Wallet] = [],
        coinbaseEnabled: Bool = true,
        onError: @escaping (Error) -> Void = { _ in }
    ) {
        Pair.configure(metadata: metadata)
        
        Web3Modal.config = Web3Modal.Config(
            projectId: projectId,
            metadata: metadata,
            sessionParams: sessionParams,
            includeWebWallets: includeWebWallets,
            recommendedWalletIds: recommendedWalletIds,
            excludedWalletIds: excludedWalletIds,
            customWallets: customWallets,
            coinbaseEnabled: coinbaseEnabled,
            onError: onError
        )
        
        let store = Store.shared
        let router = Router()
        let w3mApiInteractor = W3MAPIInteractor(store: store)
        let signInteractor = SignInteractor(store: store)
        let blockchainApiInteractor = BlockchainAPIInteractor(store: store)
        
        store.customWallets = customWallets
        
        configureCoinbaseIfNeeded(
            store: store,
            metadata: metadata,
            w3mApiInteractor: w3mApiInteractor
        )
        
        Web3Modal.viewModel = Web3ModalViewModel(
            router: router,
            store: store,
            w3mApiInteractor: w3mApiInteractor,
            signInteractor: signInteractor,
            blockchainApiInteractor: blockchainApiInteractor
        )
        
        Task {
            try? await w3mApiInteractor.fetchWalletImages(for: store.recentWallets + store.customWallets)
            try? await w3mApiInteractor.fetchAllWalletMetadata()
            try? await w3mApiInteractor.fetchFeaturedWallets()
            try? await w3mApiInteractor.prefetchChainImages()
        }
    }
    
    public static func set(sessionParams: SessionParams) {
        Web3Modal.config.sessionParams = sessionParams
    }
    
    private static func configureCoinbaseIfNeeded(
        store: Store,
        metadata: AppMetadata,
        w3mApiInteractor: W3MAPIInteractor
    ) {
        guard Web3Modal.config.coinbaseEnabled else { return }
        
        if let redirectLink = metadata.redirect?.universal ?? metadata.redirect?.native {
            CoinbaseWalletSDK.configure(callback: URL(string: redirectLink)!)
        } else {
            CoinbaseWalletSDK.configure(
                callback: URL(string: "w3mdapp://")!
            )
        }
            
        var wallet: Wallet = .init(
            id: "fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa",
            name: "Coinbase",
            homepage: "https://www.coinbase.com/wallet/",
            imageId: "a5ebc364-8f91-4200-fcc6-be81310a0000",
            order: 4,
            mobileLink: nil,
            desktopLink: nil,
            webappLink: nil,
            appStore: "https://apps.apple.com/us/app/coinbase-wallet-nfts-crypto/id1278383455",
            alternativeConnectionMethod: {
                CoinbaseWalletSDK.shared.initiateHandshake { result, account in
                    switch result {
                        case .success:
                            guard
                                let account = account,
                                let blockchain = Blockchain(
                                    namespace: account.chain == "eth" ? "eip155" : "",
                                    reference: String(account.networkId)
                                )
                            else { return }
                        
                            store.connectedWith = .cb
                            store.account = .init(
                                address: account.address,
                                chain: blockchain
                            )
                        
                            withAnimation {
                                store.isModalShown = false
                            }
                            Web3Modal.viewModel.router.setRoute(Router.AccountSubpage.profile)
                            
                            let matchingChain = ChainPresets.ethChains.first(where: {
                                $0.chainNamespace == blockchain.namespace && $0.chainReference == blockchain.reference
                            })
                        
                            store.selectedChain = matchingChain
                        case .failure(let error):
                            store.toast = .init(style: .error, message: error.localizedDescription)
                    }
                }
            }
        )
            
        wallet.isInstalled = CoinbaseWalletSDK.isCoinbaseWalletInstalled()
            
        store.customWallets.append(wallet)
            
        Task { [wallet] in
            try? await w3mApiInteractor.fetchWalletImages(for: [wallet])
        }
    }
}

#if canImport(UIKit)

public extension Web3Modal {
    static func selectChain(from presentingViewController: UIViewController? = nil) {
        guard let vc = presentingViewController ?? topViewController() else {
            assertionFailure("No controller found for presenting modal")
            return
        }
        
        _ = Web3Modal.instance
        
        Web3Modal.viewModel.router.setRoute(Router.NetworkSwitchSubpage.selectChain)
        
        Store.shared.connecting = true
        
        let modal = Web3ModalSheetController(router: Web3Modal.viewModel.router)
        vc.present(modal, animated: true)
    }
    
    static func present(from presentingViewController: UIViewController? = nil) {
        guard let vc = presentingViewController ?? topViewController() else {
            assertionFailure("No controller found for presenting modal")
            return
        }
        
        _ = Web3Modal.instance
        
        Store.shared.connecting = true
        
        Web3Modal.viewModel.router.setRoute(Store.shared.account != nil ? Router.AccountSubpage.profile : Router.ConnectingSubpage.connectWallet)
        
        let modal = Web3ModalSheetController(router: Web3Modal.viewModel.router)
        vc.present(modal, animated: true)
    }
    
    private static func topViewController(_ base: UIViewController? = nil) -> UIViewController? {
        let base = base ?? UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .last { $0.isKeyWindow }?
            .rootViewController
        
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        
        return base
    }
}

#elseif canImport(AppKit)

import AppKit

public extension Web3Modal {
    static func present(from presentingViewController: NSViewController? = nil) {
        let modal = Web3ModalSheetController()
        presentingViewController!.presentAsModalWindow(modal)
    }
}

#endif

public struct SessionParams {
    public let requiredNamespaces: [String: ProposalNamespace]
    public let optionalNamespaces: [String: ProposalNamespace]?
    public let sessionProperties: [String: String]?
    
    public init(requiredNamespaces: [String: ProposalNamespace], optionalNamespaces: [String: ProposalNamespace]? = nil, sessionProperties: [String: String]? = nil) {
        self.requiredNamespaces = requiredNamespaces
        self.optionalNamespaces = optionalNamespaces
        self.sessionProperties = sessionProperties
    }
    
    public static let `default`: Self = {
        let methods: Set<String> = Set(EthUtils.ethMethods)
        let events: Set<String> = ["chainChanged", "accountsChanged"]
        let blockchains = ChainPresets.ethChains.map(\.id).compactMap(Blockchain.init)

        let namespaces: [String: ProposalNamespace] = [
            "eip155": ProposalNamespace(
                chains: blockchains,
                methods: methods,
                events: events
            )
        ]
        
        let optionalNamespaces: [String: ProposalNamespace] = [
            "solana": ProposalNamespace(
                chains: [
                    Blockchain("solana:5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp")!
                ],
                methods: [
                    "solana_signMessage",
                    "solana_signTransaction"
                ], events: []
            )
        ]
       
        return SessionParams(
            requiredNamespaces: [:],
            optionalNamespaces: namespaces.merging(optionalNamespaces, uniquingKeysWith: { old, _ in old }),
            sessionProperties: nil
        )
    }()
}
