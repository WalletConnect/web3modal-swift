import class CoinbaseWalletSDK.CoinbaseWalletSDK
import struct CoinbaseWalletSDK.Action
import struct CoinbaseWalletSDK.ActionError
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
    public var sessionResponsePublisher: AnyPublisher<W3MResponse, Never> {
        signClient.sessionResponsePublisher
            .map { response in
                W3MResponse(
                    id: response.id,
                    topic: response.topic,
                    chainId: response.chainId,
                    result: response.result
                )
            }
            .merge(with: coinbaseResponseSubject)
            .eraseToAnyPublisher()
    }
    
    public var coinbaseResponseSubject = PassthroughSubject<W3MResponse, Never>()
    
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
    
    public func request(_ request: W3MJSONRPC) async throws {
        switch store.connectedWith {
        case .wc:
            guard
                let session = getSessions().first,
                let chain = getSelectedChain(),
                let blockchain = Blockchain(namespace: chain.chainNamespace, reference: chain.chainReference)
            else { return }
            
            if case let .personal_sign(address, message) = request {
                try await signClient.request(
                    params: .init(
                        topic: session.topic,
                        method: request.rawValues.method,
                        params: AnyCodable(any: [message, address]),
                        chainId: blockchain
                    )
                )
            } else {
                try await signClient.request(
                    params: .init(
                        topic: session.topic,
                        method: request.rawValues.method,
                        params: AnyCodable(any: request.rawValues.params),
                        chainId: blockchain
                    )
                )
            }
        case .cb:
                    
            guard let jsonRpc = request.toCbAction() else { return }
                    
            // Execute on main as Coinbase SDK is not dispatching on main when calling UIApplication.openUrl()
            DispatchQueue.main.async {
                CoinbaseWalletSDK.shared.makeRequest(
                    .init(
                        actions: [
                            Action(jsonRpc: jsonRpc)
                        ]
                    )
                ) { result in
                    let response: W3MResponse
                    switch result {
                    case let .success(payload):
                        
                        switch payload.content.first {
                        case let .success(JSONString):
                            response = .init(result: .response(AnyCodable(JSONString)))
                        case let .failure(error):
                            response = .init(result: .error(.init(code: error.code, message: error.message)))
                        case .none:
                            response = .init(result: .error(.init(code: -1, message: "Empty response")))
                        }
                    case let .failure(error):
                        Web3Modal.config.onError(error)
                        
                        if let cbError = error as? ActionError {
                            response = .init(result: .error(.init(code: cbError.code, message: cbError.message)))
                        } else {
                            response = .init(result: .error(.init(code: -1, message: error.localizedDescription)))
                        }
                    }
                    
                    self.coinbaseResponseSubject.send(response)
                }
            }
        case .magic:
            
            // TODO: Send request to Magic SDK
            assertionFailure()
        case .none:
            break
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
        switch store.connectedWith {
        case .wc:
            do {
                try await signClient.disconnect(topic: topic)
            } catch {
                Web3Modal.config.onError(error)
                throw error
            }
        case .cb:
            CoinbaseWalletSDK.shared.resetSession()
        case .magic:
            await Web3Modal.magicService?.disconnect()
        case .none:
            break
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
    
    public func getAddress() -> String? {
        guard let account = store.account else { return nil }
        
        return account.address
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
    
    @discardableResult
    public func handleDeeplink(_ url: URL) -> Bool {
        do {
            return try CoinbaseWalletSDK.shared.handleResponse(url)
        } catch {
            store.toast = .init(style: .error, message: error.localizedDescription)
            return false
        }
    }
}
