import Combine
import SwiftUI
import WalletConnectSign
import WalletConnectUtils

class Web3ModalViewModel: ObservableObject {
    private(set) var router: Router
    private(set) var store: Store
    private var w3mApiInteractor: W3MAPIInteractor
    private var signInteractor: SignInteractor
    private var blockchainApiInteractor: BlockchainAPIInteractor

    var isShown: Binding<Bool>
    
    private var disposeBag = Set<AnyCancellable>()
    
    init(
        router: Router,
        store: Store,
        w3mApiInteractor: W3MAPIInteractor,
        signInteractor: SignInteractor,
        blockchainApiInteractor: BlockchainAPIInteractor,
        isShown: Binding<Bool>
    ) {
        self.router = router
        self.isShown = isShown
        self.store = store
        self.w3mApiInteractor = w3mApiInteractor
        self.signInteractor = signInteractor
        self.blockchainApiInteractor = blockchainApiInteractor
        
        signInteractor.sessionResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink { response in
                print(response)
            }
            .store(in: &disposeBag)
        
        signInteractor.sessionSettlePublisher
            .receive(on: DispatchQueue.main)
            .sink { session in
                print(session)
                withAnimation {
                    isShown.wrappedValue = false
                }
                router.setRoute(Router.AccountSubpage.profile)
                store.session = session
                
                if
                    let blockchain = session.accounts.first?.blockchain,
                    let matchingChain = ChainsPresets.ethChains.first(where: { $0.chainNamespace == blockchain.namespace && $0.chainReference == blockchain.reference })
                {
                    store.selectedChain = matchingChain
                }
                
                self.fetchIdentity()
            }
            .store(in: &disposeBag)
        
        signInteractor.sessionRejectionPublisher
            .receive(on: DispatchQueue.main)
            .sink { _, reason in
                
                print(reason)
                
                Task {
                    try? await signInteractor.createPairingAndConnect()
                }
            }
            .store(in: &disposeBag)
        
        signInteractor.sessionDeletePublisher
            .receive(on: DispatchQueue.main)
            .sink { topic, _ in
                
                if store.session?.topic == topic {
                    store.session = nil
                }
                router.setRoute(Router.ConnectingSubpage.connectWallet)
            }
            .store(in: &disposeBag)
        
        signInteractor.sessionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { sessions in
                
                if sessions.isEmpty {
                    DispatchQueue.main.async {
                        store.session = nil
                        router.setRoute(Router.ConnectingSubpage.connectWallet)
                    }
                }
            }
            .store(in: &disposeBag)
        
        signInteractor.sessionEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { (event: Session.Event, _: String, _: Blockchain?) in
                
                switch event.name {
                case "chainChanged":
                    guard let chainReference = try? event.data.get(Int.self) else {
                        return
                    }
                    
                    store.selectedChain = ChainsPresets.ethChains.first(where: { $0.chainReference == String(chainReference) })
                    
                default:
                    return
                }
            }
            .store(in: &disposeBag)
        
        Task {
            try? await signInteractor.createPairingAndConnect()
        }
    }
    
    func fetchIdentity() {
        Task {
            do {
                try await blockchainApiInteractor.getIdentity()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchBalance() {
        Task {
            do {
                try await blockchainApiInteractor.getBalance()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func switchChain(_ to: Chain) async {
        guard let from = store.selectedChain else { return }
        
        do {
            try await switchEthChain(from: from, to: to)
        } catch {
            print(error.localizedDescription)
        
            // TODO: Call addChain only if the error code is 4902
            
            do {
                try await addEthChain(from: from, to: to)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        DispatchQueue.main.async {
            if self.store.session != nil {
                self.router.setRoute(Router.AccountSubpage.profile)
            } else {
                self.router.setRoute(Router.ConnectingSubpage.connectWallet)
            }
        }
    }
    
    @discardableResult
    private func switchEthChain(
        from: Chain,
        to: Chain
    ) async throws -> String? {
        guard let session = store.session else { return nil }
        guard let chainIdNumber = Int(to.chainReference) else { return nil }
        
        let chainHex = String(format: "%X", chainIdNumber)
        
        try await Web3Modal.instance.request(params:
            .init(
                topic: session.topic,
                method: EthUtils.walletSwitchEthChain,
                params: AnyCodable([AnyCodable(ChainSwitchParams(chainId: "0x\(chainHex)"))]),
                chainId: .init(from.id)!
            )
        )
        
        let result = try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = Web3Modal.instance.sessionResponsePublisher
                .sink { response in
                    defer { cancellable?.cancel() }
                    switch response.result {
                    case .response(let value):
                        do {
                            let string = try value.get(String.self)
                            continuation.resume(returning: string)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    case .error(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
        
        DispatchQueue.main.async {
            self.store.selectedChain = to
        }
        
        return result
    }

    @discardableResult
    private func addEthChain(
        from: Chain,
        to: Chain
    ) async throws -> String? {
        guard let session = store.session else { return nil }
        
        try await Web3Modal.instance.request(params:
            .init(
                topic: session.topic,
                method: EthUtils.walletAddEthChain,
                params: AnyCodable([AnyCodable(createAddEthChainParams(chain: to))]),
                chainId: .init(from.id)!
            )
        )
        
        let result = try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = Web3Modal.instance.sessionResponsePublisher
                .sink { response in
                    defer { cancellable?.cancel() }
                    switch response.result {
                    case .response(let value):
                        do {
                            let string = try value.get(String.self)
                            continuation.resume(returning: string)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    case .error(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
        
        DispatchQueue.main.async {
            self.store.selectedChain = to
        }
        
        return result
    }

    func createAddEthChainParams(chain: Chain) -> ChainAddParams? {
        guard let chainIdNumber = Int(chain.chainReference) else { return nil }
        
        let chainHex = String(format: "%X", chainIdNumber)
        
        return ChainAddParams(
            chainId: "0x\(chainHex)",
            blockExplorerUrls: [
                chain.blockExplorerUrl
            ],
            chainName: chain.chainName,
            nativeCurrency: .init(
                name: chain.token.name,
                symbol: chain.token.symbol,
                decimals: chain.token.decimal
            ),
            rpcUrls: [
                chain.rpcUrl
            ],
            iconUrls: [
                chain.imageId
            ]
        )
    }
    
    struct ChainAddParams: Codable {
        let chainId: String
        let blockExplorerUrls: [String]
        let chainName: String
        let nativeCurrency: NativeCurrency
        let rpcUrls: [String]
        let iconUrls: [String]
        
        struct NativeCurrency: Codable {
            let name: String
            let symbol: String
            let decimals: Int
        }
    }
    
    struct ChainSwitchParams: Codable {
        let chainId: String
    }
    
    func getChains() -> [Chain] {
        guard let namespaces = store.session?.namespaces.values else {
            return []
        }
        
        var chains = namespaces
            .compactMap { $0.chains }
            .flatMap { $0 }
            .filter { chain in
                isChainIdCAIP2Compliant(chainId: chain.absoluteString)
            }
        
        if let requiredNamespaces = store.session?.requiredNamespaces.values {
            let requiredChains = requiredNamespaces
                .compactMap { $0.chains }
                .flatMap { $0 }
                .filter { chain in
                    isChainIdCAIP2Compliant(chainId: chain.absoluteString)
                }
            
            chains.append(contentsOf: requiredChains)
        }
        
        return chains
            .compactMap { chain in
                ChainsPresets.ethChains.first(where: { chain.reference == $0.chainReference && chain.namespace == $0.chainNamespace })
            }
    }
    
    func isChainIdCAIP2Compliant(chainId: String) -> Bool {
        let elements = chainId.split(separator: ":")
        guard elements.count == 2 else { return false }

        let namespace = String(elements[0])
        let reference = String(elements[1])
        
        return isNamespaceRegexCompliant(key: namespace) && referenceRegex.matches(in: reference, options: [], range: NSRange(location: 0, length: reference.utf16.count)).count > 0
    }

    private let referenceRegex = try! NSRegularExpression(pattern: "^[-_a-zA-Z0-9]{1,32}$")

    // For namespace key validation reference check CAIP-2: https://github.com/ChainAgnostic/CAIPs/blob/master/CAIPs/caip-2.md#syntax
    func isNamespaceRegexCompliant(key: String) -> Bool {
        return namespaceRegex.matches(in: key, options: [], range: NSRange(location: 0, length: key.utf16.count)).count > 0
    }

    private let namespaceRegex = try! NSRegularExpression(pattern: "^[-a-z0-9]{3,8}$")
}
