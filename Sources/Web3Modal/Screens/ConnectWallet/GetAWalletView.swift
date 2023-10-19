import SwiftUI
import Web3ModalUI

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
                    imageContent: { _ in
                        AsyncImage(url: URL(string: "https://api.web3modal.com/getWalletImage/\(wallet.imageId)")) { image in 
                            image.resizable()
                        } placeholder: {
                            Image.Wallet
                        }
                    }
                ))
            }
                
            Button(action: {
                router.openURL(URL(string: "https://walletconnect.com/explorer?type=wallet")!)
            }, label: {
                Text("Explorer all")
            })
            .buttonStyle(W3MListSelectStyle(
                imageContent: { _ in
                    W3MAllWalletsImage(images: [
                        .init(image: Image("MockWalletImage", bundle: .UIModule), walletName: "Metamask"),
                        .init(image: Image("MockWalletImage", bundle: .UIModule), walletName: "Trust"),
                        .init(image: Image("MockWalletImage", bundle: .UIModule), walletName: "Safe"),
                        .init(image: Image("MockWalletImage", bundle: .UIModule), walletName: "Rainbow"),
                    ])
                }
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
