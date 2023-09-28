import SwiftUI

struct Web3ModalView: View {
    @ObservedObject var viewModel: Web3ModalViewModel

    var body: some View {
        VStack(spacing: 0) {
            modalHeader()
                
            Divider()
                
            routes()
        }
        .background(Color.Background125)
        .cornerRadius(30, corners: [.topLeft, .topRight])
    }
    
    @ViewBuilder
    private func routes() -> some View {
        switch viewModel.router.currentRoute as? Router.ConnectingSubpage {
        case .none:
            EmptyView()
        case .connectWallet:
            content()
        case .allWallets:
            AllWalletsView()
        case .qr:
            ConnectWithQRCode()
        case .whatIsAWallet:
            WhatIsWalletView()
        case .walletDetail:
            EmptyView()
        case .getWallet:
            GetAWalletView(
                wallets: Wallet.stubList
            )
        }
    }
    
    private func modalHeader() -> some View {
        HStack(spacing: 0) {
            switch viewModel.router.currentRoute as? Router.ConnectingSubpage {
            case .none:
                EmptyView()
            case .connectWallet:
                helpButton()
            default:
                backButton()
            }
            
            Spacer()
            
            (viewModel.router.currentRoute as? Router.ConnectingSubpage)?.title.map { title in
                Text(title)
                    .font(.paragraph700)
            }
            
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
                viewModel.router.setRoute(Router.ConnectingSubpage.qr)
            }, label: {
                Text("WalletConnect")
            })
            .buttonStyle(W3MListSelectStyle(
                imageContent: {
                    ZStack {
                        Color.Blue100
                        
                        Image.imageLogo
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white)
                    }
                },
                tag: W3MTag(title: "QR Code", variant: .main)
            ))
                
            Button(action: {}, label: {
                Text("Rainbow")
            })
            .buttonStyle(W3MListSelectStyle(
                imageContent: { Image("MockWalletImage", bundle: .module).resizable() }
            ))
                
            Button(action: {
                viewModel.router.setRoute(Router.ConnectingSubpage.allWallets)
            }, label: {
                Text("All wallets")
            })
            .buttonStyle(W3MListSelectStyle(
                imageContent: {
                    W3MAllWalletsImage(images: [
                        .init(image: Image("MockWalletImage", bundle: .module), walletName: "Metamask"),
                        .init(image: Image("MockWalletImage", bundle: .module), walletName: "Trust"),
                        .init(image: Image("MockWalletImage", bundle: .module), walletName: "Safe"),
                        .init(image: Image("MockWalletImage", bundle: .module), walletName: "Rainbow"),
                    ])
                }
            ))
        }
        .padding(Spacing.s)
        .padding(.bottom)
    }
    
    private func helpButton() -> some View {
        Button(action: {
            viewModel.router.setRoute(Router.ConnectingSubpage.whatIsAWallet)
        }, label: {
            Image.QuestionMarkCircle
        })
    }
    
    private func backButton() -> some View {
        Button {
            viewModel.router.goBack()
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

extension Router.ConnectingSubpage {
    var title: String? {
        switch self {
        case .connectWallet:
            return "Connect Wallet"
        case .qr:
            return "Scan QR Code"
        case .allWallets:
            return "All wallets"
        case .whatIsAWallet:
            return "What is a Wallet?"
        case let .walletDetail(wallet):
            return "\(wallet.name)"
        case .getWallet:
            return "Get wallet"
        }
    }
}

struct Web3ModalView_Previews: PreviewProvider {
    static var previews: some View {
        Web3ModalView(
            viewModel: .init(
                router: Router(),
                store: Store(),
                w3mApiInteractor: W3MAPIInteractor(store: Store()),
                signInteractor: SignInteractor(store: Store()),
                isShown: .constant(true)
            ))
            .previewLayout(.sizeThatFits)
    }
}
