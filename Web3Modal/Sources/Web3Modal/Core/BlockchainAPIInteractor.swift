import Foundation
import HTTPClient

final class BlockchainAPIInteractor: ObservableObject {
    
    private let store: Store
    
    init(store: Store = .shared) {
        self.store = store
    }
    
    func getIdentity() async throws {
        
        let account = store.session?.accounts.first
        let address = account?.address
        let chainId = account?.blockchainIdentifier
                
        let httpClient = HTTPNetworkClient(host: "rpc.walletconnect.com", session: URLSession(configuration: .ephemeral))
        let response = try await httpClient.request(
            Identity.self,
            at: BlockchainAPI.getIdentity(
                params: .init(
                    address: address ?? "",
                    chainId: chainId ?? "",
                    projectId: Web3Modal.config.projectId
                )
            )
        )
        
        DispatchQueue.main.async { [self] in
            self.store.identity = response
        }
    }
}


struct Identity: Codable {
    let name: String?
    let avatar: String?
}
