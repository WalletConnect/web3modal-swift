import Combine
import WalletConnectSign

final class SignInteractor: ObservableObject {
    
    lazy var sessionSettlePublisher: AnyPublisher<Session, Never> = Web3Modal.instance.sessionSettlePublisher
    lazy var sessionRejectionPublisher: AnyPublisher<(Session.Proposal, Reason), Never> = Web3Modal.instance.sessionRejectionPublisher
    
    func createPairingAndConnect() async throws -> WalletConnectURI? {
        try await Web3Modal.instance.connect(topic: nil)
    }
}
