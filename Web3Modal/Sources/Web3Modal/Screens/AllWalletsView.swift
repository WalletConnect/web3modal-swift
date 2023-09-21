import SwiftUI

struct AllWalletsView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var store: Store
    @EnvironmentObject var interactor: Web3ModalInteractor
    
    @State var searchTerm: String = ""
    
    var filteredWallets: [Wallet] {
        store.wallets.filter {
            searchTerm.isEmpty ? true : $0.name.lowercased().contains(searchTerm.lowercased())
        }
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
                    ForEach(filteredWallets, id: \.self) { wallet in
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
                    
                    if (interactor.page < interactor.totalPage) {
                        ForEach(1...8, id: \.self) { wallet in
                            Button(action: { }, label: { Text("Wallet") })
                            .buttonStyle(W3MCardSelectStyle(
                                variant: .wallet,
                                imageContent: {
                                    Color.clear.modifier(ShimmerBackground())
                                },
                                isLoading: .constant(true)
                            ))
                        }
                        .onAppear {
                            fetchWallets()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .frame(maxHeight: 600)
        }
    }
    
    private func fetchWallets() {
        Task {
            do {
                try await interactor.getWallets()
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
