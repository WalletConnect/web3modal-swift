import SwiftUI
import Web3ModalUI

struct Web3ModalView: View {
    @StateObject var router: Router
    @StateObject var store: Store
    @StateObject var interactor: W3MAPIInteractor
    
    init() {
        let store = Store()
        _router = StateObject(wrappedValue: Router())
        _store = StateObject(wrappedValue: store)
        _interactor = StateObject(
            wrappedValue: W3MAPIInteractor(store: store)
        )
        
        ImageLoader.headers = [
            "x-sdk-type": "w3m",
            "x-sdk-version": "ios-3.0.0-alpha.0",
            "x-project-id": Web3Modal.config?.projectId ?? ""
        ]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            modalHeader()
                
            Divider()
                
            switch router.currentRoute.subpage {
            case .connectWallet:
                content()
            case .allWallets:
                AllWalletsView()
            case .qr:
                ConnectWithQRCode(uri: ConnectWithQRCode_Previews.stubUri)
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
        .environmentObject(router)
        .environmentObject(store)
        .environmentObject(interactor)
        .background(Color.Background125)
        .cornerRadius(30, corners: [.topLeft, .topRight])
    }
    
    private func modalHeader() -> some View {
        HStack(spacing: 0) {
            switch router.subpage {
            case .connectWallet:
                helpButton()
            default:
                backButton()
            }
            
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
                imageContent: { Image("MockWalletImage", bundle: .UIModule).resizable() }
            ))
                
            Button(action: {
                router.subpage = .allWallets
            }, label: {
                Text("All wallets")
            })
            .buttonStyle(W3MListSelectStyle(
                imageContent: {
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
    
    private func helpButton() -> some View {
        Button(action: {
            router.subpage = .whatIsAWallet
        }, label: {
            Image.QuestionMarkCircle
        })
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
        Web3ModalView()
            .previewLayout(.sizeThatFits)
    }
}
