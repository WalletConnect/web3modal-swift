import UIKit

private class BundleProvider {
    static let bundle = Bundle(for: BundleProvider.self)
}

public extension UIImage {
    static var imageBrowser: UIImage { UIImage(named: #function)! }
    static var imageDao: UIImage { UIImage(named: #function)! }
    static var imageDeFi: UIImage { UIImage(named: #function)! }
    static var imageDefiAlt: UIImage { UIImage(named: #function)! }
    static var imageEth: UIImage { UIImage(named: #function)! }
    static var imageLayers: UIImage { UIImage(named: #function)! }
    static var imageLock: UIImage { UIImage(named: #function)! }
    static var imageLogin: UIImage { UIImage(named: #function)! }
    static var imageNft: UIImage { UIImage(named: #function)! }
    static var imageNetwork: UIImage { UIImage(named: #function)! }
    static var imageNoun: UIImage { UIImage(named: #function)! }
    static var imageProfile: UIImage { UIImage(named: #function)! }
    static var imageSystem: UIImage { UIImage(named: #function)! }
    static var optionBrowser: UIImage { UIImage(named: #function)! }
    static var optionExtension: UIImage { UIImage(named: #function)! }
    static var optionQrCode: UIImage { UIImage(named: #function)! }
}
