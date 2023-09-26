import Foundation
import Combine
import SwiftUI

@dynamicMemberLookup
class Router: ObservableObject {
    
    @Published var currentRoute: Route = .init()
    
    private let uiApplicationWrapper: UIApplicationWrapper
    
    init(uiApplicationWrapper: UIApplicationWrapper = .live) {
        self.uiApplicationWrapper = uiApplicationWrapper
        
        $currentRoute
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &subscriptions)
    }
    
    subscript<V: Equatable>(dynamicMember path: WritableKeyPath<Route, V>) -> V {
        get {
            currentRoute[keyPath: path]
        }
        set {
            if currentRoute[keyPath: path] == newValue {
                return
            }
            withAnimation {
                currentRoute[keyPath: path] = newValue
            }
        }
    }
    
    func navigateToExternalLink(_ url: URL) {
        uiApplicationWrapper.openURL(url, nil)
    }
    
    func resetRoute() {
        withAnimation {
            currentRoute = Route()
        }
    }
    
    private var subscriptions = Set<AnyCancellable>()
}

struct Route: Equatable {

    var subpage: Subpage = .connectWallet
    enum Subpage: Equatable {
        case connectWallet
        case qr
        case allWallets
        case whatIsAWallet
        case walletDetail(Wallet)
        case getWallet
    }
}

// MARK: Router for previews

extension Router {
    static func forPreview(with modifications: (Router) -> Void) -> Router {
        let router = Router()
        router.resetRoute()
        modifications(router)
        return router
    }
}
