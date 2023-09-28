import Combine
import SwiftUI

class Web3ModalViewModel: ObservableObject {
    @Published var router: Router
    @Published var store: Store
    @Published var w3mApiInteractor: W3MAPIInteractor
    @Published var signInteractor: SignInteractor

    var isShown: Binding<Bool>
    
    private var disposeBag = Set<AnyCancellable>()
    
    init(
        router: Router,
        store: Store,
        w3mApiInteractor: W3MAPIInteractor,
        signInteractor: SignInteractor,
        isShown: Binding<Bool>
    ) {
        self.router = router
        self.isShown = isShown
        self.store = store
        self.w3mApiInteractor = w3mApiInteractor
        self.signInteractor = signInteractor
        
        signInteractor.sessionSettlePublisher
            .receive(on: DispatchQueue.main)
            .sink { session in
                print(session)
                withAnimation {
                    isShown.wrappedValue = false
                }
                router.setRoute(Router.AccountSubpage.profile)
                store.session = session
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
    }
}
