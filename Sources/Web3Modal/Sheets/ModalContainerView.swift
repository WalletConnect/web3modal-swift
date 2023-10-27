import SwiftUI

struct ModalContainerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var showModal: Bool = false
    
    var store: Store
    @StateObject var router: Router
    @StateObject var w3mApiInteractor: W3MAPIInteractor
    @StateObject var signInteractor: SignInteractor
    @StateObject var blockchainApiInteractor: BlockchainAPIInteractor
    
    init(store: Store = .shared, router: Router) {
        self.store = store
        _router = StateObject(wrappedValue: router)
        _w3mApiInteractor = StateObject(
            wrappedValue: W3MAPIInteractor(store: store)
        )
        _signInteractor = StateObject(
            wrappedValue: SignInteractor(store: store)
        )
        _blockchainApiInteractor = StateObject(
            wrappedValue: BlockchainAPIInteractor(store: store)
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Color.clear
            
            if self.showModal {
                Group {
                    switch router.currentRoute {
                        case _ where router.currentRoute as? Router.AccountSubpage != nil:
                            AccountView(isModalShown: $showModal)
                        case _ where router.currentRoute as? Router.ConnectingSubpage != nil:
                            
                            Web3ModalView(
                                viewModel: .init(
                                    router: router,
                                    store: store,
                                    w3mApiInteractor: w3mApiInteractor,
                                    signInteractor: signInteractor,
                                    blockchainApiInteractor: blockchainApiInteractor,
                                    isShown: $showModal
                                )
                            )
                        case _ where router.currentRoute as? Router.NetworkSwitchSubpage != nil:
                            ChainSelectView(
                                viewModel: .init(
                                    router: router,
                                    store: store,
                                    w3mApiInteractor: w3mApiInteractor,
                                    signInteractor: signInteractor,
                                    blockchainApiInteractor: blockchainApiInteractor,
                                    isShown: $showModal
                                )
                            )
                        default:
                            EmptyView()
                    }
                }
                .transition(.move(edge: .bottom))
                .animation(.spring(), value: self.showModal)
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
                .opacity(self.showModal ? 1 : 0)
                .transform {
                    #if os(iOS)
                        $0.onTapGesture {
                            withAnimation {
                                self.showModal = false
                            }
                        }
                    #endif
                }
        )
        .edgesIgnoringSafeArea(.all)
        .onChange(of: self.showModal, perform: { newValue in
            if newValue == false {
                withAnimation {
                    self.dismiss()
                }
            }
        })
        .onAppear {
            withAnimation {
                self.showModal = true
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
