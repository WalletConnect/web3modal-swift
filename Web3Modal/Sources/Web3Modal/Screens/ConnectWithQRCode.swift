import SwiftUI

struct ConnectWithQRCode: View {
    
    let uri: String
    
    var body: some View {
    
        VStack(spacing: Spacing.xl) {
            QRCodeView(uri: uri)
                .cornerRadius(10)
            
            Text("Scan this QR code with your phone")
                .font(.paragraph500)
                .foregroundColor(.Foreground100)
            
            Button(action: {
                UIPasteboard.general.string = uri
            }, label: {
                Text("Copy Link")
            })
            .buttonStyle(W3MActionEntryStyle(leftIcon: .LargeCopy))
        }
        .padding([.top, .horizontal], Spacing.xl)
        .padding(.bottom, Spacing.l)
        .padding(.bottom)
        .background(.Background125)
    }
}

struct ConnectWithQRCode_Previews: PreviewProvider {
    static let stubUri: String = Array(repeating: ["a", "b", "c", "1", "2", "3"], count: 30)
        .flatMap { $0 }
        .shuffled()
        .joined()
    
    static var previews: some View {
        ConnectWithQRCode(uri: stubUri)
    }
}
