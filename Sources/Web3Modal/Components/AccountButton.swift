import SwiftUI
import WalletConnectSign
import Web3ModalUI

struct AccountButtonStyle: ButtonStyle {
    @EnvironmentObject var store: Store
    
    @Environment(\.isEnabled) var isEnabled
    
    var isPressedOverride: Bool?
    
    var addressFormatted: String? {
        guard let address = store.session?.accounts.first?.address else {
            return nil
        }
        
        return String(address.prefix(4)) + "..." + String(address.suffix(4))
    }
    
    var selectedChain: Chain {
        return store.selectedChain ?? ChainsPresets.ethChains.first!
    }
    
    func makeBody(configuration: Configuration) -> some View {
        var textColor: Color = .Foreground100
        textColor = isEnabled ? textColor : .Overgray015
        
        var textColorInner: Color = .Foreground200
        textColorInner = isEnabled ? textColorInner : .Overgray010
        
        var backgroundColor: Color = .GrayGlass002
        let pressedColor: Color = .GrayGlass010
        backgroundColor = (isPressedOverride ?? configuration.isPressed) ? pressedColor : backgroundColor
        backgroundColor = isEnabled ? backgroundColor : .Overgray010
        
        let verticalPadding = Spacing.xxxs
        let leadingPadding = Spacing.xxs
        let trailingPadding = Spacing.xxxs
        
        return HStack(spacing: Spacing.xs) {
            HStack(spacing: Spacing.xxs) {
                networkImage()
                    .clipShape(Circle())
                    .saturation(isEnabled ? 1 : 0)
                    .opacity(isEnabled ? 1 : 0.5)
                    .frame(width: 24, height: 24)
                
                if store.balance != nil {
                    let balance = store.balance?.roundedDecimal(to: 4, mode: .down) ?? 0
                        
                    Text(balance == 0 ? "0 \(selectedChain.token.symbol)" : "\(balance, specifier: "%.3f") \(selectedChain.token.symbol)")
                        .font(.paragraph600)
                        .foregroundColor(textColor)
                        .lineLimit(1)
                }
            }
            
            HStack(spacing: Spacing.xxs) {
                avatar()
                    
                Text(addressFormatted ?? "")
                    .font(.paragraph500)
                    .foregroundColor(textColorInner)
            }
            .padding(Spacing.xs)
            .background(.GrayGlass005)
            .cornerRadius(Radius.m)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.m)
                    .stroke(Color.Overgray010, lineWidth: 1)
            )
        }
        
        .padding(.vertical, verticalPadding)
        .padding(.leading, leadingPadding)
        .padding(.trailing, trailingPadding)
        .background(backgroundColor)
        .cornerRadius(Radius.m)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.m)
                .stroke(Color.Overgray010, lineWidth: 1)
        )
    }
    
    func networkImage() -> some View {
        Image.imageEth
            .resizable()
    }
    
    @ViewBuilder
    func avatar() -> some View {
        Group {
            if let avatarUrlString = store.identity?.avatar, let url = URL(string: avatarUrlString) {
                AsyncImage(url: url)
            } else if let address = store.session?.accounts.first?.address {
                W3MAvatarGradient(address: address)
            }
        }
        .saturation(isEnabled ? 1 : 0)
        .opacity(isEnabled ? 1 : 0.5)
        .frame(width: 20, height: 20)
        .clipShape(Circle())
        .overlay(Circle().stroke(.GrayGlass010, lineWidth: 3))
    }
}

public struct AccountButton: View {
    public init() {}
    
    public var body: some View {
        Button(action: {}, label: {
            Text("Foo")
        })
        .buttonStyle(AccountButtonStyle())
    }
}

struct AccountButton_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            AccountButton()
            
            AccountButton()
                .disabled(true)
            
            Button(action: {}, label: {
                Text("Foo")
            })
            .buttonStyle(AccountButtonStyle(isPressedOverride: true))
        }
        .environmentObject({ () -> Store in
            let store = Store()
            store.balance = 1.23
            store.session = try? JSONDecoder().decode(Session.self, from: Session.stubJson)
            return store
        }())
    }
}

private extension Session {
    static let stubJson: Data = """
    {
      "peer": {
        "name": "MetaMask Wallet",
        "url": "https://metamask.io/",
        "icons": [],
        "redirect": {
          "native": "metamask://",
          "universal": "https://metamask.app.link/"
        },
        "description": "MetaMask Wallet Integration"
      },
      "namespaces": {
        "eip155": {
          "chains": [
            "eip155:56"
          ],
          "accounts": [
            "eip155:56:0x5c8877144d858e41d8c33f5baa7e67a5e0027e37"
          ],
          "events": [
            "chainChanged",
            "accountsChanged"
          ],
          "methods": [
            "wallet_addEthereumChain",
            "personal_sign",
            "eth_sendTransaction",
            "eth_signTypedData",
            "wallet_switchEthereumChain"
          ]
        }
      },
      "pairingTopic": "08698f505aa6f677823953cbe3d5f34e4f098635f2444096d88977c1850267bb",
      "requiredNamespaces": {},
      "expiryDate": 720702756,
      "topic": "34afbcab97c8b9105f66ea3770cb540d59085c6f0996b4170cb163fee2558f59"
    }
    """.data(using: .utf8)!
}
