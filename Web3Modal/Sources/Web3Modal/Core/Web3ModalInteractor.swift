import Combine
import Foundation
import WalletConnectSign
import UIKit

final class Web3ModalInteractor: ObservableObject {
    var store: Store
    var page: Int = 0
    var totalPage: Int = 1
    var totalEntries: Int = 0
        
    init(store: Store) {
        self.store = store
    }
    
    lazy var sessionSettlePublisher: AnyPublisher<Session, Never> = Web3Modal.instance.sessionSettlePublisher
    lazy var sessionRejectionPublisher: AnyPublisher<(Session.Proposal, Reason), Never> = Web3Modal.instance.sessionRejectionPublisher
    
    func getWallets() async throws {
        page = min(page + 1, totalPage)
        let entries = 40
        
        let httpClient = HTTPNetworkClient(host: "api.web3modal.com")
        let response = try await httpClient.request(
            GetWalletsResponse.self,
            at: Web3ModalAPI.getWallets(
                params: .init(
                    page: page,
                    entries: entries,
                    projectId: Web3Modal.config.projectId,
                    metadata: Web3Modal.config.metadata,
                    recommendedIds: Web3Modal.config.recommendedWalletIds,
                    excludedIds: Web3Modal.config.excludedWalletIds
                )
            )
        )
    
        try await fetchWalletImages(for: response.data)
        
        totalEntries = response.count
        totalPage = Int(ceil(Double(response.count) / Double(entries)))
        
        DispatchQueue.main.async {
            self.store.wallets.append(contentsOf: response.data)
        }
    }
    
    func fetchWalletImages(for wallets: [Wallet]) async throws {
        
        var walletImages: [String: UIImage] = [:]
        
        await wallets.asyncForEach { wallet in
            
            let url = URL(string: "https://api.web3modal.com/getWalletImage/\(wallet.imageId)")!
            var request = URLRequest(url: url)
            
            request.setValue(Web3Modal.config.projectId, forHTTPHeaderField: "x-project-id")
            request.setValue("w3m", forHTTPHeaderField: "x-sdk-type")
            request.setValue("ios-3.0.0-alpha.0", forHTTPHeaderField: "x-sdk-version")
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                walletImages[wallet.imageId] = UIImage(data: data)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        DispatchQueue.main.async {
            self.store.walletImages.merge(walletImages) { current, new in
                new
            }
        }
    }
    
    func createPairingAndConnect() async throws -> WalletConnectURI? {
        try await Web3Modal.instance.connect(topic: nil)
    }
}

extension Sequence {
    func concurrentForEach(
        _ operation: @escaping (Element) async -> Void
    ) async {
        // A task group automatically waits for all of its
        // sub-tasks to complete, while also performing those
        // tasks in parallel:
        await withTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask {
                    await operation(element)
                }
            }
        }
    }
    
    func asyncForEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}
