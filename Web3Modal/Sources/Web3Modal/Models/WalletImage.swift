import SwiftUI

struct WalletImage {
    let image: Image?
    let url: String?
    let walletName: String?
    
    init(url: String, walletName: String?) {
        self.image = nil
        self.url = url
        self.walletName = walletName
    }
    
    init(image: Image, walletName: String?) {
        self.image = image
        self.url = nil
        self.walletName = walletName
    }
}
