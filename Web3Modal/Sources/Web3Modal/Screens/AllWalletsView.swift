import SwiftUI
import Combine

struct AllWalletsView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var store: Store
    @EnvironmentObject var interactor: Web3ModalInteractor
    
    @State var searchTerm: String = ""
    let searchTermPublisher = PassthroughSubject<String, Never>()
    
    var isSearching: Bool {
        searchTerm.count >= 2
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Search wallet", text: $searchTerm)
                    .padding(Spacing.xs)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12).stroke(.GrayGlass005, lineWidth: 1.0)
                    }
                qrButton()
            }
            .padding(.horizontal)
            .padding(.vertical, Spacing.xs)
            
            let collumns = [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
            ]
            
            ScrollView {
                LazyVGrid(columns: collumns) {
                    ForEach(isSearching ? store.searchedWallets : store.wallets, id: \.self) { wallet in
                        Button(action: {
                            router.subpage = .walletDetail(wallet)
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
                    
                    if interactor.isLoading || interactor.page < interactor.totalPage {
                        ForEach(1 ... 4, id: \.self) { _ in
                            Button(action: {}, label: { Text("Wallet") })
                                .buttonStyle(W3MCardSelectStyle(
                                    variant: .wallet,
                                    imageContent: {
                                        
                                        Color.Overgray005
//                                        Color.clear.modifier(ShimmerBackground())
                                    },
                                    isLoading: .constant(true)
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
            .frame(maxHeight: 600)
            .onChange(of: searchTerm) { searchTerm in
                searchTermPublisher.send(searchTerm)
            }
            .onReceive(
                searchTermPublisher
                    .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
                    .filter { string in
                        string.count >= 2
                    }
                    .removeDuplicates()
            ) { debouncedSearchTerm in
                store.searchedWallets = []
                fetchWallets(search: debouncedSearchTerm)
            }
        }
    }
    
    private func fetchWallets(search: String = "") {
        Task {
            do {
                try await interactor.getWallets(search: search)
            } catch {
                print(error.localizedDescription)
                // TODO: Handle error
            }
        }
    }
    
    private func qrButton() -> some View {
        Button {
            router.subpage = .qr
        } label: {
            Image.Qrcode
        }
    }
}
