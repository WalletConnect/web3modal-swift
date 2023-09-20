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
                ConnectWithQRCode(uri: ConnectWithQRCode_Previews.stubUri)
            case .whatIsAWallet:
                EmptyView()
            case .walletDetail:
                EmptyView()
            }
        }
        .environmentObject(router)
        .background(Color.Background125)
        .cornerRadius(30, corners: [.topLeft, .topRight])
    }
    
    @State var searchTerm: String = ""
    
    @ViewBuilder
    private func allWallets() -> some View {
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
                    ForEach(0 ..< 100) { _ in
                        Button(action: {
                            router.subpage = .walletDetail
                        }, label: {
                            Text("Wallet")
                        })
                        .buttonStyle(W3MCardSelectStyle(
                            variant: .wallet, image: Image("MockWalletImage", bundle: .module)
                        ))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .frame(maxHeight: 400)
        }
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
        .frame(height: 64)
        .frame(maxWidth: .infinity)
        .foregroundColor(.Foreground100)
        .overlay(
            RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
                .stroke(Color.GrayGlass005, lineWidth: 1)
        )
        .cornerRadius(30, corners: [.topLeft, .topRight])
    }
    
    private func content() -> some View {
        VStack {
            Button(action: {
                router.subpage = .qr
            }, label: {
                Text("WalletConnect")
            })
            .buttonStyle(W3MListSelectStyle(
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
        .padding(Spacing.s)
        .padding(.bottom)
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
    
    private func qrButton() -> some View {
        Button {
            router.subpage = .qr
        } label: {
            Image.Qrcode
        }
    }
}

extension Route.Subpage {
    var title: String {
        switch self {
        case .connectWallet:
            return "Connect Wallet"
        case .qr:
            return "Scan QR Code"
        case .allWallets:
            return "All wallets"
        case .whatIsAWallet:
            return "foo"
        case .walletDetail:
            return "bar"
        }
    }
}

struct Web3ModalView_Previews: PreviewProvider {
    static var previews: some View {
        Web3ModalView()
            .previewLayout(.sizeThatFits)
    }
}
