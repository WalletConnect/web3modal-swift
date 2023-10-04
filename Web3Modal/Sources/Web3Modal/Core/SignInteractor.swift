import Foundation
import Combine
import WalletConnectSign

class SignInteractor: ObservableObject {
    
    private let store: Store
    
    lazy var sessionsPublisher: AnyPublisher<[Session], Never> = Web3Modal.instance.sessionsPublisher
    lazy var sessionSettlePublisher: AnyPublisher<Session, Never> = Web3Modal.instance.sessionSettlePublisher
    lazy var sessionResponsePublisher: AnyPublisher<Response, Never> = Web3Modal.instance.sessionResponsePublisher
    lazy var sessionRejectionPublisher: AnyPublisher<(Session.Proposal, Reason), Never> = Web3Modal.instance.sessionRejectionPublisher
    lazy var sessionDeletePublisher: AnyPublisher<(String, Reason), Never> = Web3Modal.instance.sessionDeletePublisher
    
    init(store: Store = .shared) {
        self.store = store
    }
    
    func createPairingAndConnect() async throws {
        let uri = try await Web3Modal.instance.connect(topic: nil)
        
        DispatchQueue.main.async {
            self.store.uri = uri
        }
    }
    
    func disconnect() async throws {
        defer {
            DispatchQueue.main.async {
                self.store.session = nil
            }
        }
        
        try await Web3Modal.instance.disconnect(topic: store.session?.topic ?? "")
    }
}
