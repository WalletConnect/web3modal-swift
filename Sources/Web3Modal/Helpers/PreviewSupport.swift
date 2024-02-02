import SwiftUI
import Foundation

#if DEBUG

class MockWebSocketConnecting: WebSocketConnecting {
    init() {
        self.onConnect = nil
        self.onDisconnect = nil
        self.onText = nil
        self.request = URLRequest(url: URL(string: "www.google.com")!)
    }
    
    var isConnected: Bool { false }
    var onConnect: (() -> Void)?
    var onDisconnect: ((Error?) -> Void)?
    var onText: ((String) -> Void)?
    var request: URLRequest
    func connect() {}
    func disconnect() {}
    func write(string: String, completion: (() -> Void)?) {}
}

struct MockSockFactory: WebSocketFactory {
    public init() {}
    
    public func create(with url: URL) -> WebSocketConnecting {
        return MockWebSocketConnecting()
    }
}

extension Router {
    static let mock: Router = .init()
    
    static func mockWith(currentRoute: any SubPage) -> Router {
        mock.setRoute(currentRoute)
        return mock
    }
}

extension Store {
    
    static let mock: Store = .init()
    
    static func mockWith(_ mutation: (Store) -> Store) -> Store {
        mutation(mock)
    }
}

extension View {
    
    func mockSetup() {
        
        let projectId = "" // your project_id goes here
        
        assert(projectId != "", "Please provide a project id")
        
        let metadata = AppMetadata(
            name: "Web3Modal Swift Dapp",
            description: "Web3Modal DApp sample",
            url: "www.web3modal.com",
            icons: ["https://avatars.githubusercontent.com/u/37784886"],
            redirect: .init(native: "w3mdapp://", universal: nil)
        )
        
        Networking.configure(
            groupIdentifier: "group.com.walletconnect.web3modal",
            projectId: projectId,
            socketFactory: MockSockFactory()
        )
        
        Web3Modal.configure(
            projectId: projectId,
            metadata: metadata,
            store: .mock
        )
    }
    
    func withMockSetup() -> some View {
        mockSetup()
    
        return self
    }
    
    func mockStore(_ mutation: (Store) -> Void) -> some View {
        _ = mutation(Store.mock)
        return self
    }
}

#endif
