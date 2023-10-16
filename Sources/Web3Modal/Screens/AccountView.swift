import SwiftUI
import Web3ModalUI

struct AccountView: View {
    
    @EnvironmentObject var router: Router
    @EnvironmentObject var blockchainApiInteractor: BlockchainAPIInteractor
    @EnvironmentObject var signInteractor: SignInteractor
    @EnvironmentObject var store: Store
    
    @Binding var isModalShown: Bool
    
    var addressFormatted: String? {
        guard let address = store.session?.accounts.first?.address else {
            return nil
        }
        
        return String(address.prefix(4)) + "..." + String(address.suffix(4))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Image.imageNft
                .resizable()
                .frame(width: 64, height: 64)
                .clipShape(Circle())
                .overlay(Circle().stroke(.GrayGlass005, lineWidth: 8))
            
            Spacer()
                .frame(height: Spacing.xl)
            
            HStack {
                (store.identity?.name ?? addressFormatted).map {
                    Text($0)
                        .font(.title600)
                        .foregroundColor(.Foreground100)
                }
                
                Button { 
                    UIPasteboard.general.string = store.session?.accounts.first?.address
                } label: {
                    Image.LargeCopy
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.Foreground250)
                }
            }
            
            Spacer()
                .frame(height: Spacing.xxxxs)
            
            Text("\(store.balance ?? 0) \(store.selectedChain.token.symbol)")
                .font(.paragraph500)
                .foregroundColor(.Foreground200)
            
            Spacer()
                .frame(height: Spacing.s)
            
            Button {
                router.navigateToExternalLink(URL(string: store.selectedChain.blockExplorerUrl)!)
            } label: {
                Text("Block Explorer")
            }
            .buttonStyle(W3MChipButtonStyle(
                variant: .transparent,
                size: .s,
                leadingImage: {
                    Image.Compass
                        .resizable()
                },
                trailingImage: {
                    Image.ExternalLink
                        .resizable()
                }
            ))
            
            Spacer()
                .frame(height: Spacing.xl)

            Button {
                router.setRoute(Router.NetworkSwitchSubpage.selectChain)
            } label: {
                Text(store.selectedChain.chainName)
            }
            .buttonStyle(W3MListSelectStyle(imageContent: { scale in
                Image(
                    uiImage: store.chainImages[store.selectedChain.imageId] ?? UIImage()
                )
                .resizable()
                .clipShape(Circle())
            }))
            
            Spacer()
                .frame(height: Spacing.xs)
            
            Button {
                disconnect()
            } label: {
                Text("Disconnect")
            }
            .buttonStyle(W3MListSelectStyle(imageContent: { scale in
                Image.Disconnect
                    .resizable()
                    .frame(width: 22, height: 22)
            }))
            
            Spacer()
                .frame(height: Spacing.m)
            
        }
        .padding(.horizontal)
        .padding(.top, 40)
        .padding(.bottom)
        .onAppear {
            
            Task {
                do {
                    try await blockchainApiInteractor.getBalance()
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            guard store.identity == nil else {
                return
            }
            
            Task {
                do {
                    try await blockchainApiInteractor.getIdentity()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.Background125)
        .overlay(closeButton().padding().foregroundColor(.Foreground100), alignment: .topTrailing)
        .cornerRadius(30, corners: [.topLeft, .topRight])
    }
    
    func disconnect() {
        Task {
            do {
                router.setRoute(Router.ConnectingSubpage.connectWallet)
                try await signInteractor.disconnect()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func closeButton() -> some View {
        Button {
            withAnimation {
                $isModalShown.wrappedValue = false
            }
        } label: {
            Image.LargeClose
        }
    }
}
