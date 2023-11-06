import Combine
import SwiftUI
import Web3ModalUI

struct AllWalletsView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var store: Store
    @EnvironmentObject var interactor: W3MAPIInteractor
    
    @State var searchTerm: String = ""
    let searchTermPublisher = PassthroughSubject<String, Never>()
    
    @State private var keyboardHeight: CGFloat = 0
    
    var isSearching: Bool {
        searchTerm.count >= 2
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                W3MTextField("Search wallet", text: $searchTerm)
                    
                qrButton()
            }
            .padding(.horizontal)
            .padding(.vertical, Spacing.xs)
            
            
            if isSearching {
                searchGrid()
            } else {
                regularGrid()
            }
        }
        .animation(.default, value: isSearching)
        .frame(height: 600)
        .onChange(of: searchTerm) { searchTerm in
            searchTermPublisher.send(searchTerm)
        }
        .onReceive(
            searchTermPublisher
                .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
                .filter { string in
                    string.count >= 2
                }
                .removeDuplicates()
        ) { debouncedSearchTerm in
            store.searchedWallets = []
            fetchWallets(search: debouncedSearchTerm)
        }
    }
    
    @ViewBuilder
    private func regularGrid() -> some View {
        let collumns = Array(repeating: GridItem(.flexible()), count: 4)
        
        ScrollView {
            LazyVGrid(columns: collumns) {
                ForEach(store.wallets, id: \.self) { wallet in
                    gridElement(for: wallet)
                }
                
                if interactor.isLoading || interactor.page < interactor.totalPage {
                    ForEach(1 ... 8, id: \.self) { _ in
                        Button(action: {}, label: { Text("Wallet") })
                            .buttonStyle(W3MCardSelectStyle(
                                variant: .wallet,
                                imageContent: {
                                    Color.Overgray005.modifier(ShimmerBackground())
                                },
                                isLoading: $interactor.isLoading
                            ))
                    }
                    .onAppear {
                        if !interactor.isLoading { fetchWallets() }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
    
    @ViewBuilder
    private func searchGrid() -> some View {
        Group {
            
                ZStack(alignment: .center) {
                    Spacer().frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    ProgressView()
                        .opacity(interactor.isLoading ? 1 : 0)
                    
                    let collumns = Array(repeating: GridItem(.flexible()), count: 4)
                    
                    ScrollView {
                        LazyVGrid(columns: collumns) {
                            ForEach(store.searchedWallets, id: \.self) { wallet in
                                gridElement(for: wallet)
                            }
                        }
                        .animation(nil, value: store.searchedWallets)
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                    .opacity(interactor.isLoading ? 0 : 1)
                }
                
        }
        .animation(.default, value: interactor.isLoading)
    }
    
    private func gridElement(for wallet: Wallet) -> some View {
        Button(action: {
            router.setRoute(Router.ConnectingSubpage.walletDetail(wallet))
        }, label: {
            Text(wallet.name)
        })
        .buttonStyle(W3MCardSelectStyle(
            variant: .wallet,
            imageContent: {
                Image(
                    uiImage: store.walletImages[wallet.imageId] ?? UIImage()
                )
                .resizable()
            },
            isLoading: .constant(false)
        ))
    }
    
    private func fetchWallets(search: String = "") {
        Task {
            do {
                try await interactor.fetchWallets(search: search)
            } catch {
                store.toast = .init(style: .error, message: "Failed to fetch wallets.")
            }
        }
    }
    
    private func qrButton() -> some View {
        Button {
            router.setRoute(Router.ConnectingSubpage.qr)
        } label: {
            Image.optionQrCode
        }
    }
}

struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
    }
}

extension View {
    func keyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive())
    }
}

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

extension UIResponder {
    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    private static weak var _currentFirstResponder: UIResponder?

    @objc private func findFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }

    var globalFrame: CGRect? {
        guard let view = self as? UIView else { return nil }
        return view.superview?.convert(view.frame, to: nil)
    }
}
