import Combine
import Foundation
import SwiftUI

class Router: ObservableObject {
    @Published private(set) var currentRoute: any SubPage = Router.ConnectingSubpage.connectWallet
    private var previousRoute: (any SubPage)?
    
    private let uiApplicationWrapper: UIApplicationWrapper
    
    init(uiApplicationWrapper: UIApplicationWrapper = .live) {
        self.uiApplicationWrapper = uiApplicationWrapper
        
//        $currentRoute
//            .receive(on: DispatchQueue.main)
//            .removeDuplicates()
//            .sink { [weak self] _ in
//                self?.objectWillChange.send()
//            }
//            .store(in: &subscriptions)
    }
    
    
    func navigateToExternalLink(_ url: URL) {
        uiApplicationWrapper.openURL(url, nil)
    }
    
    func setRoute(_ route: any SubPage) {
        previousRoute = currentRoute
        withAnimation {
            currentRoute = route
        }
    }
    
    func goBack() {
        if let prev = previousRoute {
            withAnimation {
                currentRoute = prev
            }
        }
        previousRoute = nil
    }

    func resetRoute() {
        withAnimation {
            currentRoute = ConnectingSubpage.connectWallet
        }
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    enum AccountSubpage: SubPage {
        case transactions
        case profile
    }

    enum ConnectingSubpage: SubPage {
        case connectWallet
        case qr
        case allWallets
        case whatIsAWallet
        case walletDetail(Wallet)
        case getWallet
    }

    enum NetworkSwitchSubpage: SubPage {
        case selectChain
        case whatIsANetwork
    }
}

protocol SubPage: Equatable {}
