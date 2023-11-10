import SwiftUI

struct ModalContainerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var store: Store
    @StateObject var router: Router
    @StateObject var w3mApiInteractor: W3MAPIInteractor
    @StateObject var signInteractor: SignInteractor
    @StateObject var blockchainApiInteractor: BlockchainAPIInteractor
    @StateObject var web3modalViewModel: Web3ModalViewModel
    
    init(store: Store = .shared, router: Router) {
        self.store = store
        _router = StateObject(wrappedValue: router)
        let w3mApiInteractor = W3MAPIInteractor(store: store)
        _w3mApiInteractor = StateObject(
            wrappedValue: w3mApiInteractor
        )
        let signInteractor = SignInteractor(store: store)
        _signInteractor = StateObject(
            wrappedValue: signInteractor
        )
        let blockchainApiInteractor = BlockchainAPIInteractor(store: store)
        _blockchainApiInteractor = StateObject(
            wrappedValue: BlockchainAPIInteractor(store: store)
        )
        let web3modalViewModel = Web3ModalViewModel(
            router: router,
            store: store,
            w3mApiInteractor: w3mApiInteractor,
            signInteractor: signInteractor,
            blockchainApiInteractor: blockchainApiInteractor
        )
        _web3modalViewModel = StateObject(
            wrappedValue: web3modalViewModel
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
                .environmentObject(router)
                .environmentObject(store)
                .environmentObject(w3mApiInteractor)
                .environmentObject(signInteractor)
                .environmentObject(blockchainApiInteractor)
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
