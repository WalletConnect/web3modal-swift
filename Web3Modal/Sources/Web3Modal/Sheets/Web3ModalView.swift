import SwiftUI

struct Web3ModalView: View {
    
    var body: some View {
        VStack(spacing: 0) {
            modalHeader()

            Divider()
            
            content()
                .background(Color.Background125)
        }
    }
    
    private func modalHeader() -> some View {
        HStack(spacing: 0) {
            backButton()
            
            Spacer()
            
            Text("Connect Wallet") // TODO: Replace with dynamic title
            
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
        W3MListSelectStylePreviewView()
    }
    
    private func backButton() -> some View {
        Button {
            
        } label: {
            Image.LargeBackward
        }
    }
    
    private func closeButton() -> some View {
        Button {
            
        } label: {
            Image.LargeClose
        }
    }
}

struct Web3ModalView_Previews: PreviewProvider {
    static var previews: some View {
        Web3ModalView()
            .previewLayout(.sizeThatFits)
    }
}
