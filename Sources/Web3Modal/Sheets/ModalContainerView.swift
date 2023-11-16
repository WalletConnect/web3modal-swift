import SwiftUI

struct ModalContainerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var store: Store
    @StateObject var router: Router
    @StateObject var web3modalViewModel: Web3ModalViewModel
    
    init(store: Store = .shared, router: Router) {
        self.store = store
        _router = StateObject(wrappedValue: router)
        _web3modalViewModel = StateObject(
            wrappedValue: Web3Modal.viewModel
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(minHeight: 120)

            if store.isModalShown {
                Group {
                    switch router.currentRoute {
                        case _ where router.currentRoute as? Router.AccountSubpage != nil:
                            AccountView()
                        case _ where router.currentRoute as? Router.ConnectingSubpage != nil:
                            Web3ModalView(
                                viewModel: web3modalViewModel
                            )
                        case _ where router.currentRoute as? Router.NetworkSwitchSubpage != nil:
                            ChainSelectView(
                                viewModel: web3modalViewModel
                            )
                        default:
                            EmptyView()
                    }
                }
                .toastView(toast: $store.toast)
                .transition(.move(edge: .bottom))
                .animation(.spring(), value: store.isModalShown)
                .environmentObject(web3modalViewModel.router)
                .environmentObject(web3modalViewModel.store)
                .environmentObject(web3modalViewModel.w3mApiInteractor)
                .environmentObject(web3modalViewModel.signInteractor)
                .environmentObject(web3modalViewModel.blockchainApiInteractor)
            }
        }
        .background(
            Color.Overgray020
                .colorScheme(.light)
                .opacity(store.isModalShown ? 1 : 0)
                .transform {
                    #if os(iOS)
                        $0.onTapGesture {
                            withAnimation {
                                store.isModalShown = false
                            }
                        }
                    #endif
                }
        )
        .edgesIgnoringSafeArea(.all)
        .onChange(of: store.isModalShown, perform: { newValue in
            if newValue == false {
                withAnimation {
                    self.dismiss()
                }
            }
        })
        .onAppear {
            withAnimation {
                store.isModalShown = true
            }
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private func dismiss() {
        // Small delay so the sliding transition can happen before cross disolve starts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ModalContainerView_Previews: PreviewProvider {
    static var previews: some View {
        ModalContainerView(router: Router())
    }
}
