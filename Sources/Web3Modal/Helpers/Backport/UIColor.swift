import UIKit
import Web3ModalUI
import SwiftUI

extension UIColor {
    static var Foreground100: UIColor {
        if #available(iOS 14.0, *) {
            UIColor(Color.Foreground100)
        } else {
            UIColor(named: "Foreground100", in: .coreModule, compatibleWith: nil)!
        }
    }
    
    static var Background125: UIColor {
        if #available(iOS 14.0, *) {
            UIColor(Color.Background125)
        } else {
            UIColor(named: "Background125", in: .coreModule, compatibleWith: nil)!
        }
    }
    
    static var Blue100: UIColor {
        if #available(iOS 14.0, *) {
            UIColor(Color.Blue100)
        } else {
            UIColor(named: "Blue100", in: .coreModule, compatibleWith: nil)!
        }
    }
}
