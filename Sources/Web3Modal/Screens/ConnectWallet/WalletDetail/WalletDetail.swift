import SwiftUI
import Web3ModalUI

struct WalletDetail: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @EnvironmentObject var store: Store
    
    @ObservedObject var viewModel: WalletDetailViewModel
    
    @State var retryShown: Bool = false
    @State var showCopyLink: Bool = false
    
    var body: some View {
        VStack {
            if viewModel.showToggle {
                Web3ModalPicker(
                    WalletDetailViewModel.Platform.allCases,
                    selection: viewModel.preferredPlatform
                ) { item in
                        
                    HStack {
                        switch item {
                        case .native:
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
                    
                    if verticalSizeClass == .compact {
                        retryShown = true
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                retryShown = true
                            }
                        }
                    }
                }
                .onDisappear {
                    retryShown = false
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
            
            appStoreRow()
                .opacity(viewModel.preferredPlatform != .native ? 0 : 1)
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
                
                DrawingProgressView(shape: .roundedRectangleAbsolute(cornerRadius: 20), color: .Blue100, lineWidth: 3, isAnimating: .constant(true))
                    .frame(width: 100, height: 100)
            }
            .padding(.bottom, Spacing.s)
            
            Text("Continue in \(viewModel.wallet.name)")
                .font(.paragraph500)
                .foregroundColor(.Foreground100)
            
            Text(viewModel.preferredPlatform == .browser ? "Open and continue in a new browser tab" : "Accept connection request in the wallet")
                .font(.small500)
                .foregroundColor(.Foreground200)
            
            Button {
                viewModel.handle(.didTapOpen)
            } label: {
                HStack {
                    Text(viewModel.preferredPlatform == .browser ? "Open" : "Try again")
                }
                .font(.small600)
                .foregroundColor(.Blue100)
            }
            .padding(Spacing.xl)
            .buttonStyle(W3MButtonStyle(size: .m, variant: .accent, leftIcon: Image.Retry))
            
            if showCopyLink {
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
        .background(.GrayGlass005)
        .cornerRadius(Radius.xs)
    }
}
