import SwiftUI

final class WalletDetailViewModel: ObservableObject {
    enum Platform: String, CaseIterable, Identifiable {
        case native
        case browser
        
        var id: Self { self }
    }
    
    enum Event {
        case onAppear
        case didTapOpen
        case didTapAppStore
        case didTapCopy
    }
    
    let wallet: Wallet
    let router: Router
    let store: Store
    
    @Published var preferredPlatform: Platform = .native
    @Published var retryShown = false
    
    var showToggle: Bool {
        hasWebAppLink && hasMobileLink
    }
    
    var hasWebAppLink: Bool { wallet.webappLink?.isEmpty == false }
    var hasMobileLink: Bool { wallet.mobileLink?.isEmpty == false }
    
    init(
        wallet: Wallet,
        router: Router,
        store: Store = .shared
    ) {
        self.wallet = wallet
        self.router = router
        self.store = store
        preferredPlatform = wallet.mobileLink != nil ? .native : .browser
    }
    
    func handle(_ event: Event) {
        switch event {
        case .didTapCopy:
            UIPasteboard.general.string = store.uri?.absoluteString ?? ""
            store.toast = .init(style: .info, message: "Link copied")
        case .onAppear:
            navigateToDeepLink(
                wallet: wallet,
                preferBrowser: preferredPlatform == .browser
            )
            
            var wallet = wallet
            wallet.lastTimeUsed = Date()
            
            store.recentWallets.append(wallet)
        case .didTapOpen:
            navigateToDeepLink(
                wallet: wallet,
                preferBrowser: preferredPlatform == .browser
            )
            
        case .didTapAppStore:
            openAppstore(wallet: wallet)
        }
    }

    func openAppstore(wallet: Wallet) {
        guard
            let storeLinkString = wallet.appStore,
            let storeLink = URL(string: storeLinkString)
        else { return }
        
        router.openURL(storeLink)
    }
    
    func navigateToDeepLink(wallet: Wallet, preferBrowser: Bool) {
        do {
            let link = preferBrowser ? wallet.webappLink : wallet.mobileLink
            
            let urlString = try formatNativeUrlString(link)
            if let url = urlString?.toURL() {
                router.openURL(url) { success in
                    
                    print(success)
                }
            } else {
                throw DeeplinkErrors.noWalletLinkFound
            }
        } catch {
            store.toast = .init(style: .error, message: error.localizedDescription)
        }
    }

    enum DeeplinkErrors: LocalizedError {
        case noWalletLinkFound
        case uriNotCreated
        case failedToOpen
        
        var errorDescription: String? {
            switch self {
            case .noWalletLinkFound:
                return NSLocalizedString("No valid link for opening given wallet found", comment: "")
            case .uriNotCreated:
                return NSLocalizedString("Couldn't generate link due to missing connection URI", comment: "")
            case .failedToOpen:
                return NSLocalizedString("Given link couldn't be opened", comment: "")
            }
        }
    }
        
    func isHttpUrl(url: String) -> Bool {
        return url.hasPrefix("http://") || url.hasPrefix("https://")
    }
        
    func formatNativeUrlString(_ string: String?) throws -> String? {
        guard let string = string, !string.isEmpty else { return nil }
            
        if isHttpUrl(url: string) {
            return try formatUniversalUrlString(string)
        }
            
        var safeAppUrl = string
        if !safeAppUrl.contains("://") {
            safeAppUrl = safeAppUrl.replacingOccurrences(of: "/", with: "").replacingOccurrences(of: ":", with: "")
            safeAppUrl = "\(safeAppUrl)://"
        }
        
        guard let deeplinkUri = store.uri?.deeplinkUri else {
            throw DeeplinkErrors.uriNotCreated
        }
            
        return "\(safeAppUrl)wc?uri=\(deeplinkUri)"
    }
        
    func formatUniversalUrlString(_ string: String?) throws -> String? {
        guard let string = string, !string.isEmpty else { return nil }
            
        if !isHttpUrl(url: string) {
            return try formatNativeUrlString(string)
        }
            
        var plainAppUrl = string
        if plainAppUrl.hasSuffix("/") {
            plainAppUrl = String(plainAppUrl.dropLast())
        }
        
        guard let deeplinkUri = store.uri?.deeplinkUri else {
            throw DeeplinkErrors.uriNotCreated
        }
            
        return "\(plainAppUrl)/wc?uri=\(deeplinkUri)"
    }
}

private extension String {
    func toURL() -> URL? {
        URL(string: self)
    }
}
