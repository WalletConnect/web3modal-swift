import SwiftUI
import Web3ModalUI

struct NetworkDetailView: View {
    @EnvironmentObject var store: Store
    
    @ObservedObject var viewModel: NetworkDetailViewModel
    
    
    var body: some View {
        VStack {
            content()
                .onAppear {
                    viewModel.handle(.onAppear)
                }

        }
    }
    
    @ViewBuilder
    func content() -> some View {
        VStack(spacing: 0) {
            chainImage()
                .padding(.top, 20)
                .padding(.bottom, Spacing.l)
        }
        .padding(.horizontal)
        .padding(.bottom, Spacing.xl * 2)
    }
    
    func chainImage() -> some View {
        VStack(spacing: Spacing.xs) {
            Image(
                uiImage: store.chainImages[viewModel.chain.imageId] ?? UIImage()
            )
            .resizable()
            .frame(width: 80, height: 80)
            .clipShape(Polygon(count: 6, relativeCornerRadius: 0.25))
            .cornerRadius(Radius.m)
            .padding(.bottom, Spacing.s)
            
            Text(!viewModel.switchFailed ? "Approve in wallet" : "Switch declined")
                .font(.paragraph500)
                .foregroundColor(.Foreground100)
            
            Text(!viewModel.switchFailed ? "Accept connection request in your wallet" : "Switch can be declined if chain is not supported by a wallet or previous request is still active")
                .font(.small500)
                .foregroundColor(.Foreground200)
                .multilineTextAlignment(.center)
            
            if viewModel.switchFailed {
                Button {
                    viewModel.handle(.didTapRetry)
                } label: {
                    Text("Try again")
                        .font(.small600)
                        .foregroundColor(.Blue100)
                }
                .padding(Spacing.xl)
                .buttonStyle(W3MButtonStyle(size: .m, variant: .accent, leftIcon: Image.Retry))
            }
        }
    }
}
