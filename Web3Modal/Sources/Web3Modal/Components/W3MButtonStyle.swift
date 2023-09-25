import SwiftUI

struct W3MButtonStyle: ButtonStyle {
    enum Size {
        case s, m
    }
    
    enum Variant {
        case accent
        case main
    }
    
    @Environment(\.isEnabled) var isEnabled
    
    let size: Size
    let variant: Variant
    var leftIcon: Image?
    var rightIcon: Image?
    
    var isPressedOverride: Bool?
    
    init(
        size: Size = .m,
        variant: Variant = .main,
        leftIcon: Image? = nil,
        rightIcon: Image? = nil
    ) {
        self.size = size
        self.variant = variant
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
    }
    
    #if DEBUG
    init(
        size: Size = .m,
        variant: Variant = .main,
        leftIcon: Image? = nil,
        rightIcon: Image? = nil,
        isPressedOverride: Bool?
    ) {
        self.size = size
        self.variant = variant
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.isPressedOverride = isPressedOverride
    }
    #endif
    
    func makeBody(configuration: Configuration) -> some View {
        var textColor: Color = variant == .accent ? .Blue100 : .Inverse100
        textColor = isEnabled ? textColor : .Overgray015
        
        var backgroundColor: Color = variant == .accent ? .clear : .Blue100
        let pressedColor: Color = variant == .accent ? .Overgray010 : .Blue080
        backgroundColor = (isPressedOverride ?? configuration.isPressed) ? pressedColor : backgroundColor
        backgroundColor = isEnabled ? backgroundColor : .Overgray010
        
        let verticalPadding = size == .m ? Spacing.xxs : Spacing.xxxs
        let horizontalPadding = size == .m ? Spacing.xs : Spacing.xxs
        let leadingPadding = horizontalPadding + (leftIcon != nil ? 0 : Spacing.xs)
        let trailingPadding = horizontalPadding + (rightIcon != nil ? 0 : Spacing.xs)
        
        return HStack(spacing: Spacing.xxs) {
            if let leftIcon {
                leftIcon
                    .foregroundColor(textColor)
            }
    
            configuration
                .label
                .lineLimit(1)
                .font(size == .m ? .paragraph600 : .small600)
                .foregroundColor(textColor)
            
            if let rightIcon {
                rightIcon
                    .foregroundColor(textColor)
            }
        }
        .padding(.vertical, verticalPadding)
        .padding(.leading, leadingPadding)
        .padding(.trailing, trailingPadding)
        .background(backgroundColor)
        .cornerRadius(Radius.m)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.m)
                .stroke(Color.Overgray010, lineWidth: 1)
        )
    }
}

#if DEBUG
    public struct W3MButtonStylePreviewView: View {
        public init() {}
        
        public var body: some View {
            VStack(alignment: .leading) {
                Text("S")
                    .font(.title700)
                
                Text("Main")
                    .font(.large500)
                
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(size: .s))
                        
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(size: .s, leftIcon: .Desktop))
                        
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(size: .s, rightIcon: .Phone, isPressedOverride: true))
                    }
                    
                    HStack {
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(size: .s, leftIcon: .Desktop, rightIcon: .Phone))
                        
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(size: .s, leftIcon: .Desktop, rightIcon: .Phone))
                        .disabled(true)
                        
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(size: .s))
                        .disabled(true)
                    }
                }
                
                Text("Accent")
                    .font(.large500)
                
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(size: .s, variant: .accent))
                        
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(size: .s, variant: .accent, leftIcon: .Desktop))
                        
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(size: .s, variant: .accent, rightIcon: .Phone, isPressedOverride: true))
                    }
                    
                    HStack {
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(size: .s, variant: .accent, leftIcon: .Desktop, rightIcon: .Phone))
                        
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(size: .s, variant: .accent, leftIcon: .Desktop, rightIcon: .Phone))
                        .disabled(true)
                        
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(size: .s, variant: .accent))
                        .disabled(true)
                    }
                }
                
                Text("M")
                    .font(.title700)
                
                Text("Main")
                    .font(.large500)
                
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle())
                        
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(leftIcon: .Desktop))
                        
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(rightIcon: .Phone, isPressedOverride: true))
                    }
                    
                    HStack {
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(leftIcon: .Desktop, rightIcon: .Phone))
                        
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(leftIcon: .Desktop, rightIcon: .Phone))
                        .disabled(true)
                        
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle())
                        .disabled(true)
                    }
                }
                
                Text("Accent")
                    .font(.large500)
                
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(variant: .accent))
                        
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(variant: .accent, leftIcon: .Desktop))
                        
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(variant: .accent, rightIcon: .Phone, isPressedOverride: true))
                    }
                    
                    HStack {
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(variant: .accent, leftIcon: .Desktop, rightIcon: .Phone))
                        
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(variant: .accent, leftIcon: .Desktop, rightIcon: .Phone))
                        .disabled(true)
                        
                        Button(action: {}) {
                            Text("Button")
                        }
                        .buttonStyle(W3MButtonStyle(variant: .accent))
                        .disabled(true)
                    }
                }
            }
            .padding()
            .background(.Overgray002)
        }
    }

    struct W3MButtonStyle_Preview: PreviewProvider {
        static var previews: some View {
            W3MButtonStylePreviewView()
        }
    }

#endif
