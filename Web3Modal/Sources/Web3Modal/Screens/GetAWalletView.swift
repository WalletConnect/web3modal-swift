import SwiftUI

struct GetAWalletView: View {
    let wallets: [Wallet]
    
    @EnvironmentObject var router: Router
    
    var body: some View {
        VStack {
            
            ForEach(wallets, id: \.self) { wallet in
                Button(action: {
                
                }, label: {
                    Text(wallet.name)
                })
                .buttonStyle(W3MListSelectStyle(
                    imageUrl: URL(string: "https://api.web3modal.com/getWalletImage/\(wallet.imageId)")
                ))
            }
                
            Button(action: {
                router.navigateToExternalLink(URL(string: "https://walletconnect.com/explorer?type=wallet")!)
            }, label: {
                Text("Explorer all")
            })
            .buttonStyle(W3MListSelectStyle(
                allWalletsImage: W3MAllWalletsImage(images: [
                    .init(image: Image("MockWalletImage", bundle: .module), walletName: "Metamask"),
                    .init(image: Image("MockWalletImage", bundle: .module), walletName: "Trust"),
                    .init(image: Image("MockWalletImage", bundle: .module), walletName: "Safe"),
                    .init(image: Image("MockWalletImage", bundle: .module), walletName: "Rainbow"),
                ])
            ))
        }
        .padding(Spacing.s)
        .padding(.bottom)
    }
}

#if DEBUG

struct GetAWalletView_Previews: PreviewProvider {
    static var previews: some View {
        GetAWalletView(
            wallets: Wallet.stubList
        )
    }
}

#endif
