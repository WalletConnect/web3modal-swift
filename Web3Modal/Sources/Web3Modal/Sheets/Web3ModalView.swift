import SwiftUI

struct Web3ModalView: View {
    @StateObject var router = Router()
    
    var body: some View {
        VStack(spacing: 0) {
            modalHeader()
                
            Divider()
                
            switch router.currentRoute.subpage {
            case .connectWallet:
                content()
                    .background(Color.Background125)
            case .allWallets:
                allWallets()
            case .qr:
                EmptyView()
            case .whatIsAWallet:
                EmptyView()
            case .walletDetail:
                EmptyView()
            }
        }
    }
    
    private func allWallets() -> some View {
        VStack {
            Text("Foo")
        }
        .frame(height: 500)
        .background(Color.red)
        .navigationBarHidden(true)
    }
    
    private func modalHeader() -> some View {
        HStack(spacing: 0) {
            backButton()
            
            Spacer()
            
            Text(router.subpage.title)
                .font(.paragraph700)
            
            Spacer()
            
            closeButton()
        }
        .padding()
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .foregroundColor(.Foreground100)
        .background(Color.Background125)
        .overlay(
            RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
                .stroke(Color.GrayGlass005, lineWidth: 1)
        )
        .cornerRadius(30, corners: [.topLeft, .topRight])
    }
    
    private func content() -> some View {
        ScrollView {
            VStack {
                Button(action: {}, label: {
                    Text("Rainbow")
                })
                .buttonStyle(W3MListSelectStyle(
                    image: Image("MockWalletImage", bundle: .module),
                    tag: W3MTag(title: "QR Code", variant: .main)
                ))
                
                Button(action: {}, label: {
                    Text("Rainbow")
                })
                .buttonStyle(W3MListSelectStyle(
                    image: Image("MockWalletImage", bundle: .module)
                ))
                
                Button(action: {
                    router.subpage = .allWallets
                }, label: {
                    Text("All wallets")
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
            .padding()
        }
    }
    
    private func backButton() -> some View {
        Button {
            router.resetRoute()
        } label: {
            Image.LargeBackward
        }
    }
    
    private func closeButton() -> some View {
        Button {} label: {
            Image.LargeClose
        }
    }
}

extension Route.Subpage {
    
    var title: String {
        switch self {
        case .connectWallet:
            "Connect Wallet"
        case .qr:
            "Scan QR Code"
        case .allWallets:
            "All wallets"
        case .whatIsAWallet:
            "foo"
        case .walletDetail:
            "bar"
        }
    }
}

struct Web3ModalView_Previews: PreviewProvider {
    static var previews: some View {
        Web3ModalView()
            .previewLayout(.sizeThatFits)
    }
}
