import Combine
import SwiftUI

final class NetworkDetailViewModel: ObservableObject {
    enum Event {
        case onAppear
        case didTapRetry
    }
    
    @Published var switchFailed: Bool = false
    var triedAddingChain: Bool = false
    
    let chain: Chain
    let router: Router
    let store: Store
    
    init(
        chain: Chain,
        router: Router,
        store: Store = .shared
    ) {
        self.chain = chain
        self.router = router
        self.store = store
    
        Task { @MainActor [weak self] in
            for await (event, _, _) in Web3Modal.instance.sessionEventPublisher.values {
                guard let self = self else { return }
                
                switch event.name {
                case "chainChanged":
                    guard let chainReference = try? event.data.get(Int.self) else {
                        return
                    }
                    
                    self.store.selectedChain = ChainPresets.ethChains.first(where: { $0.chainReference == String(chainReference) })
                    self.router.setRoute(Router.AccountSubpage.profile)
                    
                case "accountsChanged":
                    
                    guard let account = try? event.data.get([String].self) else {
                        return
                    }
                    
                    let chainReference = account[0].split(separator: ":")[1]
                    
                    self.store.selectedChain = ChainPresets.ethChains.first(where: { $0.chainReference == String(chainReference) })
                    self.router.setRoute(Router.AccountSubpage.profile)
                default:
                    break
                }
            }
        }
        
        Task { @MainActor [weak self] in
            for await response in Web3Modal.instance.sessionResponsePublisher.values {
                guard let self = self else {
                    return
                }
                
                switch response.result {
                case .response:
                    self.store.selectedChain = chain
                    self.router.setRoute(Router.AccountSubpage.profile)
                case let .error(error):
                    
                    if error.message.contains("4001") {
                        self.switchFailed = true
                        return
                    }
                    
                    if !self.triedAddingChain {
                        guard let from = store.selectedChain else {
                            return
                        }
                        
                        self.triedAddingChain = true
                        try? await self.addEthChain(from: from, to: chain)
                    } else {
                        self.switchFailed = true
                    }
                }
            }
        }
    }
    
    func handle(_ event: Event) {
        switch event {
        case .onAppear:
            Task { @MainActor in
                // Switch chain
                await switchChain(chain)
            }
        case .didTapRetry:
            
            triedAddingChain = false
            switchFailed = false
            Task { @MainActor in
                // Retry switch chain
                await switchChain(chain)
            }
        }
    }
    
    @MainActor
    func switchChain(_ to: Chain) async {
        guard let from = store.selectedChain else { return }
        guard let session = store.session else { return }
        
        do {
            try await switchEthChain(from: from, to: to)
        } catch {
            print(error)
        }
        
        if
            let urlString = session.peer.redirect?.native ?? session.peer.redirect?.universal,
            let url = URL(string: urlString)
        {
            DispatchQueue.main.async {
                self.router.openURL(url)
            }
        }
    }
    
    @MainActor
    private func switchEthChain(
        from: Chain,
        to: Chain
    ) async throws {
        guard let session = store.session else { return }
        guard let chainIdNumber = Int(to.chainReference) else { return }
        
        let chainHex = String(format: "%X", chainIdNumber)
        try await Web3Modal.instance.request(params:
            .init(
                topic: session.topic,
                method: EthUtils.walletSwitchEthChain,
                params: AnyCodable([AnyCodable(ChainSwitchParams(chainId: "0x\(chainHex)"))]),
                chainId: .init(from.id)!
            )
        )
    }

    @MainActor
    private func addEthChain(
        from: Chain,
        to: Chain
    ) async throws {
        guard let session = store.session else { return }
                
        try await Web3Modal.instance.request(params:
            .init(
                topic: session.topic,
                method: EthUtils.walletAddEthChain,
                params: AnyCodable([AnyCodable(createAddEthChainParams(chain: to))]),
                chainId: .init(from.id)!
            )
        )
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
}

private extension AnyPublisher {
    enum AsyncError: Error {
        case finishedWithoutValue
    }
    
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var finishedWithoutValue = true
            cancellable = first()
                .receive(on: DispatchQueue.main)
                .sink { result in
                    switch result {
                    case .finished:
                        if finishedWithoutValue {
                            continuation.resume(throwing: AsyncError.finishedWithoutValue)
                        }
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    finishedWithoutValue = false
                    continuation.resume(with: .success(value))
                }
        }
    }
}
