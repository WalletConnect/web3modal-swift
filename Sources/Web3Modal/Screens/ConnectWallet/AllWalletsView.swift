import Combine
import SwiftUI
import UIKit


struct AllWalletsView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var store: Store
    @EnvironmentObject var interactor: W3MAPIInteractor
    
    @State var searchTerm: String = ""
    let searchTermPublisher = PassthroughSubject<String, Never>()
    
    private let semaphore = AsyncSemaphore(count: 1)
    
    var isSearching: Bool {
        searchTerm.count >= 2
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                W3MTextField("Search wallet", text: $searchTerm)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    
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
        .onAppear {
            fetchWallets()
        }
        .animation(.default, value: isSearching)
        .frame(maxHeight: UIScreen.main.bounds.height - 240)
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
            fetchWallets(search: debouncedSearchTerm)
        }
        .onReceive(
            searchTermPublisher
                .receive(on: DispatchQueue.main)
                .removeDuplicates()
        ) { searchTerm in
            if searchTerm.count < 2 {
                store.searchedWallets = []
            }
        }
    }
    
    @ViewBuilder
    private func regularGrid() -> some View {
        ScrollView {
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible()),
                    count: calculateNumberOfColumns()
                ),
                spacing: Spacing.l
            ) {
                ForEach(store.wallets.sorted(by: { $0.order < $1.order }), id: \.self) { wallet in
                    gridElement(for: wallet)
                }
                
                if interactor.isLoading || store.currentPage < store.totalPages {
                    ForEach(1 ... calculateNumberOfColumns() * 4, id: \.self) { _ in
                        Button(action: {}, label: { Text("Loading") })
                            .buttonStyle(W3MCardSelectStyle(
                                variant: .wallet,
                                imageContent: {
                                    Color.Overgray005.modifier(ShimmerBackground())
                                },
                                isLoading: .constant(true)
                            ))
                    }
                    .onAppear {
                        fetchWallets()
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 60)
        }
    }
    
    @ViewBuilder
    private func searchGrid() -> some View {
        Group {
            ZStack(alignment: .center) {
                Spacer().frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                ProgressView()
                    .opacity(interactor.isLoading ? 1 : 0)
                    
                let columns = Array(
                    repeating: GridItem(.flexible()),
                    count: calculateNumberOfColumns()
                )
                    
                ScrollView {
                    LazyVGrid(columns: columns, spacing: Spacing.l) {
                        ForEach(store.searchedWallets, id: \.self) { wallet in
                            gridElement(for: wallet)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
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
                    uiImage: store.walletImages[wallet.imageId] ??
                        UIImage(named: "Regular/Wallet", in: .UIModule, compatibleWith: nil) ??
                        UIImage()
                )
                .resizable()
            },
            isLoading: .constant(false)
        ))
        .id(wallet.id)
    }
    
    private func fetchWallets(search: String = "") {
        Task {
            do {
                try await semaphore.withTurn {
                    try await interactor.fetchWallets(search: search)
                }
            } catch {
                store.toast = .init(style: .error, message: "Network error")
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
    
    private func calculateNumberOfColumns() -> Int {
        let itemWidth: CGFloat = 76
        
        let screenWidth = UIScreen.main.bounds.width
        let count = floor(screenWidth / itemWidth)
        let spaceLeft = screenWidth.truncatingRemainder(dividingBy: itemWidth)
        let spacing = spaceLeft / (count - 1)
        let updatedCount = spacing < 4 ? count - 1 : count
        
        return Int(updatedCount)
    }
}
