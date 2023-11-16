import SwiftUI

public struct W3MTextField: View {
    var titleKey: LocalizedStringKey
    @Binding var text: String

    /// Whether the user is focused on this `TextField`.
    @Binding private var isEditing: Bool

    public init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>,
        isEditing: Binding<Bool> = .stored(false)
    ) {
        self.titleKey = titleKey
        self._text = text
        self._isEditing = isEditing
    }
    
    public var body: some View {
        HStack(spacing: Spacing.xs) {
            Image.Medium.magnifier
                .foregroundColor(.Foreground275)

            TextField("", text: $text, onEditingChanged: { isEditing = $0 })
                .placeHolder(Text(titleKey).foregroundColor(.Foreground275), show: text.isEmpty)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: Radius.xxxxs)
                            .fill(.GrayGlass020)
                            .frame(width: 18, height: 18)
                            .padding(.vertical, Spacing.xxxs)
                        
                        Image.Medium.xMark
                            .resizable()
                            .frame(width: 10, height: 10)
                            .foregroundColor(.Background250)
                            .blendMode(.destinationOut)
                    }
                    .compositingGroup()
                }
            }
        }
        .multilineTextAlignment(.leading)
        .foregroundColor(.Foreground100)
        .tint(.accentColor)
        .font(.paragraph500)
        .padding(.vertical, Spacing.xs)
        .padding(.horizontal, Spacing.s)
        .background(
            RoundedRectangle(cornerRadius: Radius.xxs)
                .fill(isEditing ? .GrayGlass010 : .GrayGlass005)
        )
        .background(
            RoundedRectangle(cornerRadius: Radius.xxs)
                .stroke(.GrayGlass005, lineWidth: 1)
        )
        .if(isEditing) {
            $0.background(
                ZStack {
                    RoundedRectangle(cornerRadius: Radius.xxs)
                        .fill(Color(red: 0.2, green: 0.59, blue: 1).opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: Radius.xxs)
                        .inset(by: 4)
                        .blendMode(.destinationOut)
                    
                    RoundedRectangle(cornerRadius: Radius.xxs)
                        .inset(by: 3)
                        .stroke(Color.Blue100, lineWidth: 1)
                }
                .compositingGroup()
            )
        }
    }
}

private struct PlaceHolder<T: View>: ViewModifier {
    var placeHolder: T
    var show: Bool
    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if show { placeHolder }
            content
        }
    }
}

private extension View {
    
    func placeHolder<T:View>(_ holder: T, show: Bool) -> some View {
        self.modifier(PlaceHolder(placeHolder:holder, show: show))
    }
}

struct W3MTextFieldStylePreview: PreviewProvider {
    static var previews: some View {
        VStack {
            W3MTextField("FOoo", text: .constant(""))
            W3MTextField("FOoo", text: .constant("Foo"), isEditing: .constant(true))
        }
        .padding()
    }
}
