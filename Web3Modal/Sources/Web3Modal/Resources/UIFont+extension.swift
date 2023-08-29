import UIKit

public extension UIFont {
    static func large500() -> UIFont {
        customFont("SFProText-Medium", size: 20.0)
    }

    static func large600() -> UIFont {
        customFont("SFProText-Semibold", size: 20.0)
    }

    static func large700() -> UIFont {
        customFont("SFProText-Semibold", size: 20.0)
    }

    static func micro600() -> UIFont {
        customFont("SFProText-Semibold", size: 10.0)
    }

    static func micro700() -> UIFont {
        customFont("SFProText-Bold", size: 10.0)
    }

    static func paragraph500() -> UIFont {
        customFont("SFProText-Medium", size: 16.0)
    }

    static func paragraph600() -> UIFont {
        customFont("SFProText-Semibold", size: 16.0)
    }

    static func paragraph700() -> UIFont {
        customFont("SFProText-Semibold", size: 16.0)
    }

    static func small500() -> UIFont {
        customFont("SFProText-Medium", size: 14.0)
    }

    static func small600() -> UIFont {
        customFont("SFProText-Semibold", size: 14.0)
    }

    static func tiny500() -> UIFont {
        customFont("SFProText-Medium", size: 12.0)
    }

    static func tiny600() -> UIFont {
        customFont("SFProText-Semibold", size: 12.0)
    }

    static func title500() -> UIFont {
        customFont("SFProText-Medium", size: 24.0)
    }

    static func title600() -> UIFont {
        customFont("SFProText-Medium", size: 24.0)
    }

    static func title700() -> UIFont {
        customFont("SFProText-Semibold", size: 24.0)
    }

    private static func customFont(
        _ name: String,
        size: CGFloat,
        textStyle: UIFont.TextStyle? = nil,
        scaled: Bool = false) -> UIFont
    {
        guard let font = UIFont(name: name, size: size) else {
            print("Warning: Font \(name) not found.")
            return UIFont.systemFont(ofSize: size, weight: .regular)
        }

        if scaled, let textStyle = textStyle {
            let metrics = UIFontMetrics(forTextStyle: textStyle)
            return metrics.scaledFont(for: font)
        } else {
            return font
        }
    }
}
