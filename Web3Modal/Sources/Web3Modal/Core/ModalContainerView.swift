import SwiftUI

struct ModalContainerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var showModal: Bool = false
        
    var body: some View {
        VStack(spacing: 0) {
            Color.clear
            
            if self.showModal {
                Web3ModalView()
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: self.showModal)
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
