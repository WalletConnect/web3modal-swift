import SwiftUI
import Web3ModalUI

struct WalletDetail: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @EnvironmentObject var store: Store
    
    @ObservedObject var viewModel: WalletDetailViewModel
    
    @State var retryShown: Bool = false
    @State var showCopyLink: Bool = false
    
    var body: some View {
        VStack {
            if viewModel.showToggle {
                Web3ModalPicker(
                    WalletDetailViewModel.Platform.allCases,
                    selection: viewModel.preferredPlatform
                ) { item in
                        
                    HStack {
                        switch item {
                        case .native:
                            Image(systemName: "iphone")
                        case .browser:
                            Image(systemName: "safari")
                        }
                        Text(item.rawValue.capitalized)
                    }
                    .font(.small500)
                    .multilineTextAlignment(.center)
                    .foregroundColor(viewModel.preferredPlatform == item ? .Foreground100 : .Foreground200)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.preferredPlatform = item
                        }
                    }
                }
                .pickerBackgroundColor(.GrayGlass005)
                .cornerRadius(20)
                .borderWidth(1)
                .borderColor(.GrayGlass010)
                .frame(maxWidth: 250)
                .padding()
            }
            
            content()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.handle(.onAppear)
                    }
                    
                    if verticalSizeClass == .compact {
                        retryShown = true
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                retryShown = true
                            }
                        }
                    }
                }
                .onDisappear {
                    retryShown = false
                }
                .animation(.easeInOut, value: viewModel.preferredPlatform)
        }
    }
    
    @ViewBuilder
    func content() -> some View {
        VStack(spacing: 0) {
            walletImage()
                .padding(.top, 40)
                .padding(.bottom, Spacing.l)
            
            
            
            appStoreRow()
                .opacity(viewModel.preferredPlatform != .native ? 0 : 1)
        }
        .padding(.horizontal)
        .padding(.bottom, Spacing.xl * 2)
    }
    
    func walletImage() -> some View {
        VStack(spacing: Spacing.xs) {
            Image(
                uiImage: store.walletImages[viewModel.wallet.imageId] ?? UIImage()
            )
            .resizable()
            .frame(width: 80, height: 80)
            .cornerRadius(Radius.m)
            .padding(.bottom, Spacing.s)
            
            Text("Continue in \(viewModel.wallet.name)")
                .font(.paragraph500)
                .foregroundColor(.Foreground100)
            
            Text(viewModel.preferredPlatform == .browser ? "Open and continue in a new browser tab" : "Accept connection request in the wallet")
                .font(.small500)
                .foregroundColor(.Foreground200)
            
            Button {
                viewModel.handle(.didTapOpen)
            } label: {
                HStack {
                    Text(viewModel.preferredPlatform == .browser ? "Open" : "Try again")
                }
                .font(.small600)
                .foregroundColor(.Blue100)
            }
            .padding(Spacing.xl)
            .buttonStyle(W3MButtonStyle(size: .m, variant: .accent, leftIcon: Image.Retry))
            
            if showCopyLink {
                Button {
                    viewModel.handle(.didTapCopy)
                } label: {
                    HStack {
                        Image.LargeCopy
                            .resizable()
                            .frame(width: 12, height: 12)
                        Text("Copy link")
                    }
                    .font(.small600)
                    .foregroundColor(.Foreground200)
                    .padding(Spacing.xs)
                }
            }
        }
    }
    
    func appStoreRow() -> some View {
        HStack(spacing: 0) {
            Text("Don't have \(viewModel.wallet.name)?")
                .font(.paragraph500)
                .foregroundColor(.Foreground200)
            
            Spacer()
            
            Button {
                viewModel.handle(.didTapAppStore)
            } label: {
                HStack(spacing: 4) {
                    Text("Get")
                    
                    Image(systemName: "chevron.right")
                }
                .font(.small600)
                .foregroundColor(.Blue100)
                .padding(Spacing.xs)
            }
            .overlay {
                Capsule()
                    .stroke(.GrayGlass010, lineWidth: 1)
            }
        }
        .padding()
        .frame(height: 56)
        .background(.GrayGlass005)
        .cornerRadius(Radius.xs)
    }
}

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
    let deeplinkHandler: WalletDeeplinkHandler
    let store: Store
    
    @Published var preferredPlatform: Platform = .native
    
    var showToggle: Bool { true }
    var showUniversalLink: Bool { preferredPlatform == .native && wallet.webappLink?.isEmpty == false }
    var hasNativeLink: Bool { wallet.mobileLink?.isEmpty == false }
    
    init(
        wallet: Wallet,
        deeplinkHandler: WalletDeeplinkHandler,
        store: Store = .shared
    ) {
        self.wallet = wallet
        self.deeplinkHandler = deeplinkHandler
        self.store = store
        preferredPlatform = wallet.mobileLink != nil ? .native : .browser
    }
    
    func handle(_ event: Event) {
        switch event {
        case .didTapCopy:
            UIPasteboard.general.string = store.uri?.absoluteString ?? ""
        case .onAppear:
            deeplinkHandler.navigateToDeepLink(
                wallet: wallet,
                preferBrowser: preferredPlatform == .browser
            )
            
        case .didTapOpen:
            deeplinkHandler.navigateToDeepLink(
                wallet: wallet,
                preferBrowser: preferredPlatform == .browser
            )
            
        case .didTapAppStore:
            deeplinkHandler.openAppstore(wallet: wallet)
        }
    }
}

protocol WalletDeeplinkHandler {
    func openAppstore(wallet: Wallet)
    func navigateToDeepLink(wallet: Wallet, preferBrowser: Bool)
}

extension Web3ModalViewModel: WalletDeeplinkHandler {
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
            print(error.localizedDescription)
        }
    }
}

private extension Web3ModalViewModel {
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
