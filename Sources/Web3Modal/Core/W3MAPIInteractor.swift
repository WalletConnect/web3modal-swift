import UIKit

final class W3MAPIInteractor: ObservableObject {
    @Published var isLoading: Bool = false
    
    private let store: Store
    private let uiApplicationWrapper: UIApplicationWrapper
    
    private let entriesPerPage: Int = 40
    
    var totalEntries: Int = 0
        
    init(
        store: Store = .shared,
        uiApplicationWrapper: UIApplicationWrapper = .live
    ) {
        self.store = store
        self.uiApplicationWrapper = uiApplicationWrapper
    }
    
    func fetchWallets(search: String = "") async throws {
        if search.isEmpty {
            if store.currentPage + 1 > store.totalPages {
                return
            }
            
            store.currentPage = min(store.currentPage + 1, store.totalPages)
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        let params = Web3ModalAPI.GetWalletsParams(
            page: search.isEmpty ? store.currentPage : 1,
            entries: search.isEmpty ? entriesPerPage : 100,
            search: search,
            projectId: Web3Modal.config.projectId,
            metadata: Web3Modal.config.metadata,
            recommendedIds: Web3Modal.config.recommendedWalletIds,
            excludedIds: Web3Modal.config.excludedWalletIds
        )
        
        let httpClient = HTTPNetworkClient(host: "api.web3modal.com")
        let response = try await httpClient.request(
            GetWalletsResponse.self,
            at: Web3ModalAPI.getWallets(
                params: params
            )
        )
    
        try await fetchWalletImages(for: response.data.map(\.imageId))
        
        DispatchQueue.main.async { [self] in
            var wallets = response.data.map { Wallet(dto: $0) }
                
            for index in wallets.indices {
                let contains = store.installedWalletIds.contains(wallets[index].id)
                wallets[index].isInstalled = contains
            }
            
            if !search.isEmpty {
                self.store.searchedWallets = wallets
            } else {
                self.store.searchedWallets = []
                self.store.wallets.formUnion(wallets)
                self.totalEntries = response.count
                self.store.totalPages = Int(ceil(Double(response.count) / Double(entriesPerPage)))
            }
            
            self.isLoading = false
        }
    }
    
    func fetchAllWalletMetadata() async throws {
        let httpClient = HTTPNetworkClient(host: "api.web3modal.com")
        let response = try await httpClient.request(
            GetIosDataResponse.self,
            at: Web3ModalAPI.getIosData(
                params: .init(
                    projectId: Web3Modal.config.projectId,
                    metadata: Web3Modal.config.metadata
                )
            )
        )
    
        let installedWallets: [String?] = try await response.data.concurrentMap { walletMetadata in
            guard
                let nativeUrl = URL(string: walletMetadata.ios_schema),
                await UIApplication.shared.canOpenURL(nativeUrl)
            else {
                return nil
            }
                
            return walletMetadata.id
        }
            
        store.installedWalletIds = installedWallets.compactMap { $0 }
    }
    
    func fetchFeaturedWallets() async throws {
        let httpClient = HTTPNetworkClient(host: "api.web3modal.com")
        let response = try await httpClient.request(
            GetWalletsResponse.self,
            at: Web3ModalAPI.getWallets(
                params: .init(
                    page: 1,
                    entries: 4,
                    search: "",
                    projectId: Web3Modal.config.projectId,
                    metadata: Web3Modal.config.metadata,
                    recommendedIds: Web3Modal.config.recommendedWalletIds,
                    excludedIds: Web3Modal.config.excludedWalletIds
                )
            )
        )
        
        try await fetchWalletImages(for: response.data.map(\.imageId))
        
        DispatchQueue.main.async { [self] in
            
            var wallets = response.data.map({ Wallet(dto: $0) })
                
            for index in wallets.indices {
                let contains = store.installedWalletIds.contains(wallets[index].id)
                wallets[index].isInstalled = contains
            }
            
            self.store.totalNumberOfWallets = response.count
            self.store.featuredWallets = wallets
        }
    }
    
    func fetchWalletImages(for walletImageIds: [String]) async throws {
        var walletImages: [String: UIImage] = [:]
        
        try await walletImageIds.concurrentMap { imageId in
            
            guard !self.store.walletImages.contains(where: { key, _ in
                key == imageId
            }) else {
                return ("", UIImage?.none)
            }
            
            do {
                let image = try await self.fetchWalletImage(id: imageId)
                return (imageId, image)
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
    
    func prefetchChainImages() async throws {
        var chainImages: [String: UIImage] = [:]
        
        try await ChainPresets.ethChains.concurrentMap { chain in
            do {
                let image = try await self.fetchAssetImage(id: chain.imageId)
                return (chain.imageId, image)
            } catch {
                print(error.localizedDescription)
            }
            
            return ("", UIImage?.none)
        }
        .forEach { key, value in
            if value == nil {
                return
            }
            
            chainImages[key] = value
        }
        
        DispatchQueue.main.async { [chainImages] in
            self.store.chainImages.merge(chainImages) { _, new in
                new
            }
        }
    }
    
    func fetchAssetImage(id: String) async throws -> UIImage? {
        
        let url = URL(string: "https://api.web3modal.com/public/getAssetImage/\(id)")!
        var request = URLRequest(url: url)
        request.setW3MHeaders()
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return UIImage(data: data)
    }
    
    func fetchWalletImage(id: String) async throws -> UIImage? {
        
        let url = URL(string: "https://api.web3modal.com/getWalletImage/\(id)")!
        var request = URLRequest(url: url)
        request.setW3MHeaders()
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return UIImage(data: data)
    }
}

extension URLRequest {
    
    mutating func setW3MHeaders() {
        setValue(Web3Modal.config.projectId, forHTTPHeaderField: "x-project-id")
        setValue(Web3Modal.Config.sdkType, forHTTPHeaderField: "x-sdk-type")
        setValue(Web3Modal.Config.sdkVersion, forHTTPHeaderField: "x-sdk-version")
    }
}
