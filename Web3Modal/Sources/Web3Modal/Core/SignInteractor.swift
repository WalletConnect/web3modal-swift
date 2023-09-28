import Foundation
import Combine
import WalletConnectSign

class SignInteractor: ObservableObject {
    
    private let store: Store
    
    lazy var sessionSettlePublisher: AnyPublisher<Session, Never> = Web3Modal.instance.sessionSettlePublisher
    lazy var sessionRejectionPublisher: AnyPublisher<(Session.Proposal, Reason), Never> = Web3Modal.instance.sessionRejectionPublisher
    
    init(store: Store = .shared) {
        self.store = store
    }
    
    func createPairingAndConnect() async throws {
        let uri = try await Web3Modal.instance.connect(topic: nil)
        
        DispatchQueue.main.async {
            self.store.uri = uri
        }
    }
}
