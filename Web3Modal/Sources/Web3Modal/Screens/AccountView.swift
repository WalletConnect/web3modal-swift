import SwiftUI

struct AccountView: View {
    
    @EnvironmentObject var router: Router
    @EnvironmentObject var blockchainApiInteractor: BlockchainAPIInteractor
    @EnvironmentObject var store: Store
    
    @Binding var isModalShown: Bool
    
    var addressFormatted: String? {
        guard let address = store.session?.accounts.first?.address else {
            return nil
        }
        
        return String(address.prefix(4)) + "..." + String(address.suffix(4))
    }
    
    var body: some View {
        VStack {
            AvatarView()
            
            HStack {
                
                (store.identity?.name ?? addressFormatted).map {
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
                leftIcon: Image(systemName: "network"),
                rightIcon: Image.ExternalLink
            ))

            Button {
                disconnect()
            } label: {
                Text("Disconnect")
            }
            .buttonStyle(W3MButtonStyle(
                size: .s,
                variant: .accent,
                rightIcon: Image.Disconnect
            ))
        }
        .padding()
        .padding(.bottom)
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
    
    func disconnect() {
        Task {
            do {
                try await Web3Modal.instance.disconnect(topic: store.session?.topic ?? "")
                withAnimation {
                    isModalShown = false
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(isModalShown: .constant(true))
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
