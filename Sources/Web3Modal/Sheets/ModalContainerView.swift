import SwiftUI

struct ModalContainerView: View {
    @Environment(\.presentationMode) var presentationMode
        
    @ObservedObject var store: Store
    @Backport.StateObject var router: Router
    @Backport.StateObject var web3modalViewModel: Web3ModalViewModel
    
    init(store: Store = .shared, router: Router) {
        self.store = store
        _router = Backport.StateObject(wrappedValue: router)
        _web3modalViewModel = Backport.StateObject(
            wrappedValue: Web3Modal.viewModel
        )
    }
    
    var body: some View {
        ZStack {
            Color.Overgray020
                .colorScheme(.light)
                .opacity(store.isModalShown ? 1 : 0)
                .transform {
                    #if os(iOS)
                        $0.onTapGesture {
                            withAnimation {
                                store.isModalShown = false
                                store.connecting = false
                            }
                        }
                    #endif
                }
                .edgesIgnoringSafeArea(.top)
            
            VStack(spacing: 0) {
                Spacer()
                    .background(Color.clear)
                
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
                    .background(
                        VStack {
                            Color.clear
                            
                            Color.Background125
                                .edgesIgnoringSafeArea([.bottom, .horizontal])
                        }
                    )
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
        }
        .backport.onChange(of: store.isModalShown, perform: { newValue in
            if newValue == false {
                withAnimation {
                    self.dismiss()
                    store.connecting = false
                }
            }
        })
        .onAppear {
            withAnimation {
                store.isModalShown = true
            }
        }
    }
    
    private func dismiss() {
        // Small delay so the sliding transition can happen before cross disolve starts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

@available(iOS 14.0, *)
struct ModalContainerView_Previews: PreviewProvider {
    static var previews: some View {
        ModalContainerView(router: .mock)
            .withMockSetup()
    }
}
