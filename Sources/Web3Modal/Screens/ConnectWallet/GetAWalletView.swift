import SwiftUI
import Web3ModalUI

struct GetAWalletView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var store: Store
    
    var body: some View {
        VStack {
            ForEach(store.featuredWallets.prefix(4), id: \.self) { wallet in
                Button(action: {
                    if let appstoreLink = wallet.appStore {
                        router.openURL(URL(string: appstoreLink)!)
                    }
                }, label: {
                    Text(wallet.name)
                })
                .buttonStyle(W3MListSelectStyle(
                    imageContent: { _ in
                        AsyncImage(url: URL(string: "https://api.web3modal.com/getWalletImage/\(wallet.imageId)")) { image in 
                            image.resizable()
                        } placeholder: {
                            Image.Medium.wallet
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
                    Image.optionAll
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
        GetAWalletView()
    }
}

#endif
