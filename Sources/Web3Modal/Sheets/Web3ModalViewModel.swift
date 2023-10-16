import Combine
import SwiftUI

class Web3ModalViewModel: ObservableObject {
    private var router: Router
    @Published var store: Store
    @Published var w3mApiInteractor: W3MAPIInteractor
    @Published var signInteractor: SignInteractor
    var blockchainApiInteractor: BlockchainAPIInteractor

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
                store.uri = nil
                
                self.fetchIdentity()
            }
            .store(in: &disposeBag)
        
        signInteractor.sessionRejectionPublisher
            .receive(on: DispatchQueue.main)
            .sink { _, reason in
                
                print(reason)
                
                store.uri = nil
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
        
        fetchFeaturedWallets()
    }
    
    func fetchFeaturedWallets() {
        Task {
            do {
                try await w3mApiInteractor.fetchFeaturedWallets()
            } catch {
                print(error.localizedDescription)
            }
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
}
