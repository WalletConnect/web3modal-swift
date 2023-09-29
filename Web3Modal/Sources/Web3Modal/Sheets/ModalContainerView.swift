import SwiftUI

struct ModalContainerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var showModal: Bool = false
        
    @StateObject var router: Router
    @StateObject var w3mApiInteractor: W3MAPIInteractor
    @StateObject var signInteractor: SignInteractor
    @StateObject var blockchainApiInteractor: BlockchainAPIInteractor
    
    init() {
        let router = Router()
        router.setRoute(Store.shared.session != nil ? Router.AccountSubpage.profile : Router.ConnectingSubpage.connectWallet)
        _router = StateObject(wrappedValue: router)
        _w3mApiInteractor = StateObject(
            wrappedValue: W3MAPIInteractor(store: Store.shared)
        )
        _signInteractor = StateObject(
            wrappedValue: SignInteractor(store: Store.shared)
        )
        _blockchainApiInteractor = StateObject(
            wrappedValue: BlockchainAPIInteractor(store: Store.shared)
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Color.clear
            
            if self.showModal {
                Web3ModalView(
                    viewModel: .init(
                        router: router,
                        store: Store.shared,
                        w3mApiInteractor: w3mApiInteractor,
                        signInteractor: signInteractor,
                        blockchainApiInteractor: blockchainApiInteractor,
                        isShown: $showModal
                    )
                )
                .transition(.move(edge: .bottom))
                .animation(.spring(), value: self.showModal)
                .environmentObject(router)
                .environmentObject(Store.shared)
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
        ModalContainerView()
    }
}
