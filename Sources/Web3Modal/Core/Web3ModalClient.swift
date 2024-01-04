import Combine
import Foundation
import UIKit

// Web3 Modal Client
///
/// Cannot be instantiated outside of the SDK
///
/// Access via `Web3Modal.instance`
public class Web3ModalClient {
    // MARK: - Public Properties
    
    /// Publisher that sends sessions on every sessions update
    ///
    /// Event will be emited on controller and non-controller clients.
    public var sessionsPublisher: AnyPublisher<[Session], Never> {
        signClient.sessionsPublisher.eraseToAnyPublisher()
    }
    
    /// Publisher that sends session when one is settled
    ///
    /// Event is emited on proposer and responder client when both communicating peers have successfully established a session.
    public var sessionSettlePublisher: AnyPublisher<Session, Never> {
        signClient.sessionSettlePublisher.eraseToAnyPublisher()
    }
    
    /// Publisher that sends session proposal that has been rejected
    ///
    /// Event will be emited on dApp client only.
    public var sessionRejectionPublisher: AnyPublisher<(Session.Proposal, Reason), Never> {
        signClient.sessionRejectionPublisher.eraseToAnyPublisher()
    }
    
    /// Publisher that sends deleted session topic
    ///
    /// Event can be emited on any type of the client.
    public var sessionDeletePublisher: AnyPublisher<(String, Reason), Never> {
        signClient.sessionDeletePublisher.eraseToAnyPublisher()
    }
    
    /// Publisher that sends response for session request
    ///
    /// In most cases that event will be emited on dApp client.
    public var sessionResponsePublisher: AnyPublisher<Response, Never> {
        signClient.sessionResponsePublisher.eraseToAnyPublisher()
    }
    
    /// Publisher that sends web socket connection status
    public var socketConnectionStatusPublisher: AnyPublisher<SocketConnectionStatus, Never> {
        signClient.socketConnectionStatusPublisher.eraseToAnyPublisher()
    }
    
    /// Publisher that sends session event
    ///
    /// Event will be emited on dApp client only
    public var sessionEventPublisher: AnyPublisher<(event: Session.Event, sessionTopic: String, chainId: Blockchain?), Never> {
        signClient.sessionEventPublisher.eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties

    private let signClient: SignClientProtocol
    private let pairingClient: PairingClientProtocol & PairingInteracting & PairingRegisterer
    private let store: Store
    
    init(
        signClient: SignClientProtocol,
        pairingClient: PairingClientProtocol & PairingInteracting & PairingRegisterer,
        store: Store
    ) {
        self.signClient = signClient
        self.pairingClient = pairingClient
        self.store = store
    }
    
    /// For creating new pairing
    public func createPairing() async throws -> WalletConnectURI {
        do {
            return try await pairingClient.create()
        } catch {
            Web3Modal.config.onError(error)
            throw error
        }
    }
    
    /// For proposing a session to a wallet.
    /// Function will propose a session on existing pairing or create new one if not specified
    /// Namespaces from Web3Modal.config will be used
    /// - Parameters:
    ///   - topic: pairing topic
    public func connect(
        topic: String?
    ) async throws -> WalletConnectURI? {
        do {
            if let topic = topic {
                try pairingClient.validatePairingExistance(topic)
                try await signClient.connect(
                    requiredNamespaces: Web3Modal.config.sessionParams.requiredNamespaces,
                    optionalNamespaces: Web3Modal.config.sessionParams.optionalNamespaces,
                    sessionProperties: Web3Modal.config.sessionParams.sessionProperties,
                    topic: topic
                )
                return nil
            } else {
                let pairingURI = try await pairingClient.create()
                try await signClient.connect(
                    requiredNamespaces: Web3Modal.config.sessionParams.requiredNamespaces,
                    optionalNamespaces: Web3Modal.config.sessionParams.optionalNamespaces,
                    sessionProperties: Web3Modal.config.sessionParams.sessionProperties,
                    topic: pairingURI.topic
                )
                return pairingURI
            }
        } catch {
            Web3Modal.config.onError(error)
            throw error
        }
    }
    
    /// For proposing a session to a wallet.
    /// Function will propose a session on existing pairing.
    /// - Parameters:
    ///   - requiredNamespaces: required namespaces for a session
    ///   - topic: pairing topic
    public func connect(
        requiredNamespaces: [String: ProposalNamespace],
        optionalNamespaces: [String: ProposalNamespace]? = nil,
        sessionProperties: [String: String]? = nil,
        topic: String
    ) async throws {
        do {
            try await signClient.connect(
                requiredNamespaces: requiredNamespaces,
                optionalNamespaces: optionalNamespaces,
                sessionProperties: sessionProperties,
                topic: topic
            )
        } catch {
            Web3Modal.config.onError(error)
            throw error
        }
    }
    
    /// Ping method allows to check if peer client is online and is subscribing for given topic
    ///
    ///  Should Error:
    ///  - When the session topic is not found
    ///
    /// - Parameters:
    ///   - topic: Topic of a session
    public func ping(topic: String) async throws {
        do {
            try await pairingClient.ping(topic: topic)
        } catch {
            Web3Modal.config.onError(error)
            throw error
        }
    }
    
    /// For sending JSON-RPC requests to wallet.
    /// - Parameters:
    ///   - params: Parameters defining request and related session
    public func request(params: Request) async throws {
        do {
            try await signClient.request(params: params)
        } catch {
            Web3Modal.config.onError(error)
            throw error
        }
    }
    
    /// For a terminating a session
    ///
    /// Should Error:
    /// - When the session topic is not found
    /// - Parameters:
    ///   - topic: Session topic that you want to delete
    public func disconnect(topic: String) async throws {
        do {
            try await signClient.disconnect(topic: topic)
        } catch {
            Web3Modal.config.onError(error)
            throw error
        }
    }
    
    /// Query sessions
    /// - Returns: All sessions
    public func getSessions() -> [Session] {
        signClient.getSessions()
    }
    
    /// Query pairings
    /// - Returns: All pairings
    public func getPairings() -> [Pairing] {
        pairingClient.getPairings()
    }
    
    /// Delete all stored data such as: pairings, sessions, keys
    ///
    /// - Note: Will unsubscribe from all topics
    public func cleanup() async throws {
        do {
            try await signClient.cleanup()
        } catch {
            Web3Modal.config.onError(error)
            throw error
        }
    }
    
    public func getSelectedChain() -> Chain? {
        guard let chain = store.selectedChain else {
            return nil
        }
        
        return chain
    }
    
    public func addChainPreset(_ chain: Chain) {
        ChainPresets.ethChains.append(chain)
    }
    
    public func selectChain(_ chain: Chain) {
        store.selectedChain = chain
    }
    
    public func launchCurrentWallet() {
        guard
            let session = store.session,
            let urlString = session.peer.redirect?.native ?? session.peer.redirect?.universal,
            let url = URL(string: urlString)
        else { return }
        
        DispatchQueue.main.async {
            UIApplication.shared.open(url, completionHandler: nil)
        }
    }
}
