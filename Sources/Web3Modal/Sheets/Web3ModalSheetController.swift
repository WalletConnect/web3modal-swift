import SwiftUI
import UIKit

class Web3ModalSheetController: UIHostingController<ModalContainerView> {
    @available(*, unavailable)
    @MainActor dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var showModal: Bool = false
    
    init(router: Router) {
        super.init(
            rootView: ModalContainerView(
                router: router,
                showModal: .stored(showModal)
            )
        )
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
    }
}

private extension Binding {
    static func stored(_ value: Value) -> Self {
        var value = value
        return .init(get: { value }, set: { value = $0 })
    }
}
