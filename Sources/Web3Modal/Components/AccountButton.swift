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
                avatarImage()
                    .clipShape(Circle())
                    .saturation(isEnabled ? 1 : 0)
                    .opacity(isEnabled ? 1 : 0.5)
                    .frame(width: 20, height: 20)
                
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
    
    func avatarImage() -> some View {
        Image.imageNft
            .resizable()
    }
}

struct AccountButton: View {
    var body: some View {
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
            var store = Store()
            store.balance = 1.23
//            store.session = Session
            return store
        }())
    }
}

extension Session {
    static let stub = Session(
        topic: "topic",
        pairingTopic: "pairingTopic",
        peer: AppMetadata(
            name: "name",
            description: "description",
            url: "url",
            icons: ["icons"]
        ),
        requiredNamespaces: ["requiredNamespaces": ProposalNamespace(
            description: "description",
            methods: ["methods"]
        )],
        namespaces: ["namespaces": SessionNamespace(
            description: "description",
            methods: ["methods"]
        )],
        sessionProperties: ["sessionProperties": "sessionProperties"],
        expiryDate: Date()
    )
    
    
}
