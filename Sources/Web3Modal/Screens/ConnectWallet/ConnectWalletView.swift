import SwiftUI

struct ConnectWalletView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var router: Router
    
    let displayWCConnection = false
    
    @State var email: String = "radek@walletconnect.com"
    
    var wallets: [Wallet] {
        var recentWallets = store.recentWallets
        
        let result = (store.featuredWallets + store.customWallets).map { featuredWallet in
            var featuredWallet = featuredWallet
            let (index, matchingRecentWallet) = recentWallets.enumerated().first { (index, recentWallet) in
                featuredWallet.id == recentWallet.id
            } ?? (nil, nil)
            
            
            if let match = matchingRecentWallet, let matchingIndex = index  {
                featuredWallet.lastTimeUsed = match.lastTimeUsed
                recentWallets.remove(at: matchingIndex)
            }
            
            return featuredWallet
        }
        
        return (recentWallets + result)
    }
    
    var body: some View {
        VStack {
            emailInput()
            
            Divider()
            
            wcConnection()
            
            featuredWallets()
                
            Button(action: {
                router.setRoute(Router.ConnectingSubpage.allWallets)
            }, label: {
                Text("All wallets")
            })
            .buttonStyle(W3MListSelectStyle(
                imageContent: { _ in
                    Image.optionAll
                },
                tag: store.totalNumberOfWallets != 0 ? W3MTag(title: "\(store.totalNumberOfWallets)+", variant: .info) : nil
            ))
        }
        .padding(Spacing.s)
    }
    
    @ViewBuilder
    private func emailInput() -> some View {
        TextField("Enter your email", text: $email)
            .font(.body)
            .padding(.bottom, Spacing.s)
            .backport.overlay {
                RoundedRectangle(cornerRadius: Radius.xxs)
                    .stroke(Color.Overgray010, lineWidth: 1)
            }
            .backport.overlay(alignment: .trailing) {
                Button(action: {
                    Task {
                       await Web3Modal.magicService?.connectEmail(email: email)
                    }
                }, label: {
                    Image(systemName: "chevron.right.circle.fill")
                })
                .disabled(email.count < 5) // TODO: Regex prolly?
            }
            
    }
    
    @ViewBuilder
    private func featuredWallets() -> some View {
        ForEach(wallets, id: \.self) { wallet in
            Group {
                let isRecent: Bool = wallet.lastTimeUsed != nil
                let tagTitle: String? = isRecent ? "RECENT" : nil
                
                Button(action: {
                    router.setRoute(Router.ConnectingSubpage.walletDetail(wallet))
                }, label: {
                    Text(wallet.name)
                })
                .buttonStyle(W3MListSelectStyle(
                    imageContent: { _ in
                        Group {
                            if let storedImage = store.walletImages[wallet.id] {
                                Image(uiImage: storedImage)
                                    .resizable()
                            } else {
                                Image.Regular.wallet
                                    .resizable()
                                    .padding(Spacing.xxs)
                            }
                        }
                        .background(Color.Overgray005)
                        .backport.overlay {
                            RoundedRectangle(cornerRadius: Radius.xxxs)
                                .stroke(.Overgray010, lineWidth: 1)
                        }
                    },
                    tag: tagTitle != nil ? .init(title: tagTitle!, variant: .info) : nil
                ))
            }
        }
    }
    
    @ViewBuilder
    private func wcConnection() -> some View {
        if displayWCConnection {
            Button(action: {
                router.setRoute(Router.ConnectingSubpage.qr)
            }, label: {
                Text("WalletConnect")
            })
            .buttonStyle(W3MListSelectStyle(
                imageContent: { _ in
                    ZStack {
                        Color.Blue100
                        
                        Image.imageLogo
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white)
                    }
                },
                tag: W3MTag(title: "QR CODE", variant: .main)
            ))
        }
    }
}

struct ConnectWalletView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectWalletView()
    }
}
