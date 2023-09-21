import Combine
import Foundation
import UIKit
import WalletConnectSign

final class Web3ModalInteractor: ObservableObject {
    @Published var isLoading: Bool = false
    
    var store: Store
    var page: Int = 0
    var totalPage: Int = .max
    var totalEntries: Int = 0
        
    init(store: Store) {
        self.store = store
    }
    
    lazy var sessionSettlePublisher: AnyPublisher<Session, Never> = Web3Modal.instance.sessionSettlePublisher
    lazy var sessionRejectionPublisher: AnyPublisher<(Session.Proposal, Reason), Never> = Web3Modal.instance.sessionRejectionPublisher
    
    func getWallets(search: String = "") async throws {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        if search.isEmpty {
            page = min(page + 1, totalPage)
        }
        let entries = 40
        
        print(#function, search, page, totalPage)
        
        let httpClient = HTTPNetworkClient(host: "api.web3modal.com", session: URLSession(configuration: .ephemeral))
        let response = try await httpClient.request(
            GetWalletsResponse.self,
            at: Web3ModalAPI.getWallets(
                params: .init(
                    page: search.isEmpty ? page : 1,
                    entries: search.isEmpty ? entries : 100,
                    search: search,
                    projectId: Web3Modal.config.projectId,
                    metadata: Web3Modal.config.metadata,
                    recommendedIds: Web3Modal.config.recommendedWalletIds,
                    excludedIds: Web3Modal.config.excludedWalletIds
                )
            )
        )
    
        try await fetchWalletImages(for: response.data)
        
        DispatchQueue.main.async {
            if !search.isEmpty {
                self.store.searchedWallets = response.data
            } else {
                self.store.searchedWallets = []
                self.store.wallets.append(contentsOf: response.data)
                self.totalEntries = response.count
                self.totalPage = Int(ceil(Double(response.count) / Double(entries)))
            }
            
            self.isLoading = false
        }
    }
    
    func fetchWalletImages(for wallets: [Wallet]) async throws {
        var walletImages: [String: UIImage] = [:]
        
        try await wallets.concurrentMap { wallet in
            
            guard !self.store.walletImages.contains(where: { key, _ in
                key == wallet.imageId
            }) else {
                return ("", UIImage?.none)
            }
            
            let url = URL(string: "https://api.web3modal.com/getWalletImage/\(wallet.imageId)")!
            var request = URLRequest(url: url)
            
            request.setValue(Web3Modal.config.projectId, forHTTPHeaderField: "x-project-id")
            request.setValue("w3m", forHTTPHeaderField: "x-sdk-type")
            request.setValue("ios-3.0.0-alpha.0", forHTTPHeaderField: "x-sdk-version")
            
            do {
                let (data, _) = try await URLSession(configuration: .ephemeral).data(for: request)
                return (wallet.imageId, UIImage(data: data))
            } catch {
                print(error.localizedDescription)
            }
            
            return ("", UIImage?.none)
        }
        .forEach { key, value in
            
            if value == nil {
                return
            }
            
            walletImages[key] = value
        }
        
        DispatchQueue.main.async { [walletImages] in
            self.store.walletImages.merge(walletImages) { _, new in
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
    
    func asyncMap<T>(
           _ transform: (Element) async throws -> T
       ) async rethrows -> [T] {
           var values = [T]()

           for element in self {
               try await values.append(transform(element))
           }

           return values
       }
    
    func concurrentMap<T>(
        _ transform: @escaping (Element) async throws -> T
    ) async throws -> [T] {
        let tasks = map { element in
            Task {
                try await transform(element)
            }
        }

        return try await tasks.asyncMap { task in
            try await task.value
        }
    }
}
