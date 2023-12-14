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
            signClient: Sign.instance,
            pairingClient: Pair.instance as! (PairingClientProtocol & PairingInteracting & PairingRegisterer),
            store: .shared
        )
        
        if let session = client.getSessions().first {
            Store.shared.session = session
            
            if let blockchain = session.accounts.first?.blockchain {
                let matchingChain = ChainPresets.ethChains.first(where: {
                    $0.chainNamespace == blockchain.namespace && $0.chainReference == blockchain.reference
                })
                
                Store.shared.selectedChain = matchingChain
            }
        }
        
        return client
    }()
    
    struct Config {
        static let sdkVersion: String = EnvironmentInfo.sdkVersion
        static let sdkType = "w3m"
        
        let projectId: String
        var metadata: AppMetadata
        var sessionParams: SessionParams
        
        let includeWebWallets: Bool
        let recommendedWalletIds: [String]
        let excludedWalletIds: [String]
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
        recommendedWalletIds: [String] = [],
        excludedWalletIds: [String] = [],
        includeWebWallets: Bool = true
    ) {
        Pair.configure(metadata: metadata)
        
        
        
        Web3Modal.config = Web3Modal.Config(
            projectId: projectId,
            metadata: metadata,
            sessionParams: sessionParams,
            includeWebWallets: includeWebWallets,
            recommendedWalletIds: recommendedWalletIds,
            excludedWalletIds: excludedWalletIds
        )
        
       
        
        let store = Store.shared
        let router = Router()
        let w3mApiInteractor = W3MAPIInteractor(store: store)
        let signInteractor = SignInteractor(store: store)
        let blockchainApiInteractor = BlockchainAPIInteractor(store: store)
        let interactor = W3MAPIInteractor()
        
        Web3Modal.viewModel = Web3ModalViewModel(
            router: router,
            store: store,
            w3mApiInteractor: w3mApiInteractor,
            signInteractor: signInteractor,
            blockchainApiInteractor: blockchainApiInteractor
        )
        
        Task {
            try? await interactor.fetchWalletImages(for: Store.shared.recentWallets)
            try? await interactor.fetchAllWalletMetadata()
            try? await interactor.fetchFeaturedWallets()
            try? await interactor.prefetchChainImages()
        }
    }
    
    public static func set(sessionParams: SessionParams) {
        Web3Modal.config.sessionParams = sessionParams
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
        
        Web3Modal.viewModel.router.setRoute(Store.shared.session != nil ? Router.AccountSubpage.profile : Router.ConnectingSubpage.connectWallet)
        
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
        let blockchains: Set<Blockchain> = Set(ChainPresets.ethChains.map(\.id).compactMap(Blockchain.init))
        
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
                    Blockchain("solana:4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ")!
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
