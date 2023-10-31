import Combine
import SwiftUI
import WalletConnectSign
import WalletConnectUtils

final class NetworkDetailViewModel: ObservableObject {
    enum Event {
        case onAppear
        case didTapRetry
    }
    
    @Published var switchFailed: Bool = false
    
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
    }
    
    func handle(_ event: Event) {
        switch event {
        case .onAppear:
            Task {
                // Switch chain
                await switchChain(chain)
            }
        case .didTapRetry:
            
            self.switchFailed = false
            Task {
                // Retry switch chain
                await switchChain(chain)
            }
        }
    }
    
    func switchChain(_ to: Chain) async {
        guard let from = store.selectedChain else { return }
        
        do {
            try await switchEthChain(from: from, to: to)
        } catch {
            print(error.localizedDescription)
            DispatchQueue.main.async {
                self.store.toast = .init(style: .error, message: "Failed to switchEthChain trying addEthChain instead")
            }
            // TODO: Call addChain only if the error code is 4902
            
            do {
                try await addEthChain(from: from, to: to)
            } catch {
                DispatchQueue.main.async {
                    self.store.toast = .init(style: .error, message: "Failed to addEthChain")
                    self.switchFailed = true
                }
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
        
        // TODO: Nice to have: Somehow open the wallet with switch confirmation dialog
        
        let event = try await Web3Modal.instance.sessionEventPublisher.async().event
        if event.name == "chainChanged" {
            DispatchQueue.main.async {
                self.store.selectedChain = to
                self.router.setRoute(Router.AccountSubpage.profile)
            }
        }
        
        let result = try await Web3Modal.instance.sessionResponsePublisher.async().result
        
        if case .response(let value) = result {
            let stringResponse = try value.get(String.self)
            
            DispatchQueue.main.async {
                self.store.selectedChain = to
                self.router.setRoute(Router.AccountSubpage.profile)
            }
            
            return stringResponse
        } else {
            return nil
        }
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
        
        let event = try await Web3Modal.instance.sessionEventPublisher.async().event
        if event.name == "chainChanged" {
            DispatchQueue.main.async {
                self.store.selectedChain = to
                self.router.setRoute(Router.AccountSubpage.profile)
            }
        }
        
        let result = try await Web3Modal.instance.sessionResponsePublisher.async().result
        
        if case .response(let value) = result {
            let stringResponse = try value.get(String.self)
            
            DispatchQueue.main.async {
                self.store.selectedChain = to
                self.router.setRoute(Router.AccountSubpage.profile)
            }
            
            return stringResponse
        } else {
            return nil
        }
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
