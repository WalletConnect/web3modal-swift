import QRCode
import SwiftUI
import Web3ModalUI

struct QRCodeView: View {
    let uri: String
    var imageData: Data? = nil
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let size: CGSize = .init(
            width: UIScreen.main.bounds.width - 20,
            height: UIScreen.main.bounds.height * 0.4
        )
        
        let height: CGFloat = min(size.width, size.height)
        
        VStack(alignment: .center) {
            render(
                content: uri,
                size: .init(width: height, height: height)
            )
            .id(colorScheme)
            .colorScheme(.light)
            .cornerRadius(Radius.l)
        }
    }
            
    @MainActor private func render(content: String, size: CGSize) -> Image {
        let doc = QRCode.Document(
            utf8String: content,
            errorCorrection: .quantize
        )
        doc.design.shape.eye = QRCode.EyeShape.Squircle()
        doc.design.shape.onPixels = QRCode.PixelShape.Vertical(
            insetFraction: 0.3,
            cornerRadiusFraction: 1
        )
        
        doc.design.additionalQuietZonePixels = 2
        
        doc.design.style.eye = QRCode.FillStyle.Solid(Foreground100.cgColor)
        doc.design.style.pupil = QRCode.FillStyle.Solid(Foreground100.cgColor)
        doc.design.style.onPixels = QRCode.FillStyle.Solid(Foreground100.cgColor)
        doc.design.style.background = QRCode.FillStyle.Solid(Background125.cgColor)
        
        let uiImage = imageData != nil ?
            UIImage(data: imageData!) :
            UIImage(named: "imageLogo",
                    in: .UIModule,
                    compatibleWith: nil)?.withColor(UIColor(.Blue100))
        
        if let uiImage = uiImage {
            let cgImage = uiImage.cgImage!
            
            let logoSize = 0.25
            let pathWidth = logoSize * (uiImage.size.width / uiImage.size.height)
            let pathHeight = logoSize
            
            doc.logoTemplate = QRCode.LogoTemplate(
                image: cgImage,
                path: CGPath(
                    rect: CGRect(x: (1 - pathWidth) / 2, y: (1 - pathHeight) / 2, width: pathWidth, height: pathHeight),
                    transform: nil
                ),
                inset: 20
            )
        }
        return doc.imageUI(
            size.applying(.init(scaleX: 3, y: 3)),
            dpi: 72 * 3,
            label: Text("QR code with URI")
        )!
    }
}

private extension UIImage {
    func withColor(_ color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let drawRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        color.setFill()
        UIRectFill(drawRect)
        draw(in: drawRect, blendMode: .destinationIn, alpha: 1)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!
    }
}

private extension QRCodeView {
    var Foreground100: UIColor {
        UIColor(Color.Foreground100)
    }
    
    var Background125: UIColor {
        UIColor(Color.Background125)
    }
}

#if DEBUG
public struct QRCodeViewPreviewView: View {
    public init() {}
    
    static let stubUri: String = Array(repeating: ["a", "b", "c", "1", "2", "3"], count: 10)
        .flatMap { $0 }
        .joined()
    
    public var body: some View {
        VStack {
            QRCodeView(
                uri: QRCodeViewPreviewView.stubUri,
                imageData: UIImage(named: "MockWalletImage", in: .UIModule, compatibleWith: nil)?.pngData()
            )
            .previewLayout(.sizeThatFits)
            
            QRCodeView(uri: QRCodeViewPreviewView.stubUri)
        }
    }
}

struct QRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeViewPreviewView()
            .previewLayout(.sizeThatFits)
    }
}
#endif
