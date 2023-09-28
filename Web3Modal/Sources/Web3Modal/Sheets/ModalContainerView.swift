import SwiftUI

struct ModalContainerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var showModal: Bool = false
        
    @StateObject var router: Router
    @StateObject var w3mApiInteractor: W3MAPIInteractor
    @StateObject var signInteractor: SignInteractor
    
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
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Color.clear
            
            if self.showModal {
                Web3ModalView(
                    viewModel: .init(
                        router: router,
                        store: Store.shared,
                        w3mApiInteractor: W3MAPIInteractor(),
                        signInteractor: SignInteractor(),
                        isShown: $showModal
                    )
                )
                .transition(.move(edge: .bottom))
                .animation(.spring(), value: self.showModal)
                .environmentObject(router)
                .environmentObject(Store.shared)
                .environmentObject(w3mApiInteractor)
                .environmentObject(signInteractor)
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
