import SwiftUI

struct W3MListSelectStyle: ButtonStyle {

    @Environment(\.isEnabled) var isEnabled

    var imageUrl: URL?
    var image: Image?
    var tag: W3MTag?

    var isPressedOverride: Bool?

    init(imageUrl: URL, tag: W3MTag? = nil) {
        self.imageUrl = imageUrl
        self.tag = tag
    }

    init(image: Image, tag: W3MTag? = nil) {
        self.image = image
        self.tag = tag
    }

    #if DEBUG
        init(
            imageUrl: URL? = nil,
            image: Image? = nil,
            tag: W3MTag? = nil,
            isPressedOverride: Bool? = nil
        ) {
            self.imageUrl = imageUrl
            self.image = image
            self.tag = tag
            self.isPressedOverride = isPressedOverride
        }
    #endif

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: Spacing.s) {
            imageComponent()
                
            configuration.label
                .font(.paragraph500)
                .foregroundColor(.Foreground100)
            
            Spacer()
            
            tag.map {
                $0.saturation(isEnabled ? 1 : 0)
            }
        
        }
        .opacity(isEnabled ? 1 : 0.5)
        .padding(.vertical, Spacing.xs)
        .padding(.leading, Spacing.xs)
        .padding(.trailing, Spacing.l)
        .background((isPressedOverride ?? configuration.isPressed) ? .Overgray010 : .Overgray005)
        .cornerRadius(Radius.xs)
        .frame(height: 56)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func imageComponent() -> some View {
        VStack {
            if let image {
                image
                    .resizable()
            } else {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                } placeholder: {
                    Image.Wallet
                }
            }
        }
        .frame(width: 40, height: 40)
        .saturation(isEnabled ? 1 : 0)
        .opacity(isEnabled ? 1 : 0.5)
        .overlay {
            RoundedRectangle(cornerRadius: Radius.xxxs)
                .strokeBorder(.Overgray010, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: Radius.xxxs).fill(.Overgray005))
        }
    }
}

 #if DEBUG
     public struct W3MListSelectStylePreviewView: View {
         public init() {}

         public var body: some View {
             VStack {
                 Button(action: {}, label: {
                     Text("Rainbow")
                 })
                 .buttonStyle(W3MListSelectStyle(
                     image: Image("MockWalletImage", bundle: .module),
                     tag: W3MTag(title: "QR Code", variant: .main)
                 ))
                 
                 Button(action: {}, label: {
                     Text("Rainbow")
                 })
                 .buttonStyle(W3MListSelectStyle(
                     tag: W3MTag(title: "Installed", variant: .success),
                     isPressedOverride: true
                 ))
                 
                 Button(action: {}, label: {
                     Text("Rainbow")
                 })
                 .buttonStyle(W3MListSelectStyle(
                     image: Image("MockWalletImage", bundle: .module)
                 ))

                 Button(action: {}, label: {
                     Text("Rainbow")
                 })
                 .buttonStyle(W3MListSelectStyle(
                     image: Image("MockWalletImage", bundle: .module),
                     tag: W3MTag(title: "QR Code", variant: .main)
                 ))
                 .disabled(true)
             }
             .padding()
             .background(.Overgray002)
         }
     }

     struct W3MListSelect_Preview: PreviewProvider {
         static var previews: some View {
             W3MListSelectStylePreviewView()
                 .previewLayout(.sizeThatFits)
         }
     }

 #endif
