import SwiftUI
import Web3ModalUI

struct WalletDetail: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @EnvironmentObject var store: Store
    
    @StateObject var viewModel: WalletDetailViewModel
    
    var body: some View {
        VStack {
            if viewModel.showToggle {
                Web3ModalPicker(
                    WalletDetailViewModel.Platform.allCases,
                    selection: viewModel.preferredPlatform
                ) { item in
                        
                    HStack {
                        switch item {
                        case .mobile:
                            Image(systemName: "iphone")
                        case .browser:
                            Image(systemName: "safari")
                        }
                        Text(item.rawValue.capitalized)
                    }
                    .font(.small500)
                    .multilineTextAlignment(.center)
                    .foregroundColor(viewModel.preferredPlatform == item ? .Foreground100 : .Foreground200)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.preferredPlatform = item
                        }
                    }
                }
                .pickerBackgroundColor(.GrayGlass005)
                .cornerRadius(20)
                .borderWidth(1)
                .borderColor(.GrayGlass010)
                .frame(maxWidth: 250)
                .padding()
            }
            
            content()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.handle(.onAppear)
                    }
                }
                .animation(.easeInOut, value: viewModel.preferredPlatform)
        }
    }
    
    @ViewBuilder
    func content() -> some View {
        VStack(spacing: 0) {
            
            walletImage()
                .padding(.top, 40)
                .padding(.bottom, Spacing.l)
            
            Button {
                viewModel.handle(.didTapCopy)
            } label: {
                HStack {
                    Image.LargeCopy
                        .resizable()
                        .frame(width: 12, height: 12)
                    Text("Copy link")
                }
                .font(.small600)
                .foregroundColor(.Foreground200)
                .padding(Spacing.xs)
            }
            .padding(.bottom, Spacing.xl)
            
            if viewModel.preferredPlatform == .mobile {
                appStoreRow()
            }
        }
        .padding(.horizontal)
        .padding(.bottom, Spacing.xl * 2)
    }
    
    func walletImage() -> some View {
        VStack(spacing: Spacing.xs) {
            ZStack {
                Image(
                    uiImage: store.walletImages[viewModel.wallet.imageId] ?? UIImage()
                )
                .resizable()
                .frame(width: 80, height: 80)
                .cornerRadius(Radius.m)
                
                if !viewModel.retryShown {
                    DrawingProgressView(
                        shape: .roundedRectangleRelative(relativeCornerRadius: Radius.m / 80),
                        color: .Blue100,
                        lineWidth: 3,
                        isAnimating: .constant(true)
                    )
                    .frame(width: 90, height: 90)
                }
            }
            .padding(.bottom, Spacing.s)
            
            Text(viewModel.retryShown ? "Connection declined" : "Continue in \(viewModel.wallet.name)")
                .font(.paragraph500)
                .foregroundColor(.Foreground100)
            
            Text(
                viewModel.retryShown
                ? "Connection can be declined if a previous request is still active"
                : viewModel.preferredPlatform == .browser ? "Open and continue in a new browser tab" : "Accept connection request in the wallet")
                .font(.small500)
                .foregroundColor(.Foreground200)
            
            if viewModel.retryShown || viewModel.preferredPlatform == .browser {
                Button {
                    viewModel.handle(.didTapOpen)
                } label: {
                    HStack {
                        Text(viewModel.preferredPlatform == .browser ? "Open" : "Try again")
                    }
                    .font(.small600)
                    .foregroundColor(.Blue100)
                }
                .buttonStyle(W3MButtonStyle(size: .m, variant: .accent, leftIcon: Image.Retry))
            }
        }
    }
    
    func appStoreRow() -> some View {
        HStack(spacing: 0) {
            Text("Don't have \(viewModel.wallet.name)?")
                .font(.paragraph500)
                .foregroundColor(.Foreground200)
            
            Spacer()
            
            Button {
                viewModel.handle(.didTapAppStore)
            } label: {
                HStack(spacing: 4) {
                    Text("Get")
                    
                    Image(systemName: "chevron.right")
                }
                .font(.small600)
                .foregroundColor(.Blue100)
                .padding(Spacing.xs)
            }
            .overlay {
                Capsule()
                    .stroke(.GrayGlass010, lineWidth: 1)
            }
        }
        .padding()
        .frame(height: 56)
        .background(.GrayGlass002)
        .cornerRadius(Radius.xs)
    }
}
