import SwiftUI

struct AccountView: View {
    
    @EnvironmentObject var router: Router
    @EnvironmentObject var blockchainApiInteractor: BlockchainAPIInteractor
    @EnvironmentObject var store: Store
    
    var body: some View {
        VStack {
            AvatarView()
            
            HStack {
                store.identity?.name.map {
                    Text($0)
                        .font(.title600)
                }
                
                Image.LargeCopy
            }
            
            Text("0.527 ETH")
            
            Button {
                router.navigateToExternalLink(URL(string: "www.chain.com/explorer")!)
            } label: {
                Text("Block Explorer")
            }
            .buttonStyle(W3MButtonStyle(
                size: .s,
                variant: .accent,
                leftIcon: Image.imageBrowser,
                rightIcon: Image.ExternalLink
            ))

        }
        .onAppear {
            
            guard store.identity == nil else { return }
            
            Task {
                do {
                    try await blockchainApiInteractor.getIdentity()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}

struct AvatarView: View {
    var body: some View {
        VStack {
            Image.imageNft
        }
    }
}

struct AvatarViewView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView()
    }
}
