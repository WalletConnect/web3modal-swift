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
                .foregroundColor(.Overgray030)

            TextField(titleKey, text: $text, onEditingChanged: { isEditing = $0 })
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image.Medium.xMark
                        .padding(Spacing.xxxs)
                        .foregroundColor(.GrayGlass020)
                        .background(.Background250)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.xxxxs))
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
                .stroke(Color.Overgray010, lineWidth: 1)
        )
        .if(isEditing) {
            $0.background(
                ZStack {
                    RoundedRectangle(cornerRadius: Radius.xxs)
                        .fill(Color(red: 0.2, green: 0.59, blue: 1).opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: Radius.xxs)
                        .inset(by: 3)
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

struct W3MTextFieldStylePreview: PreviewProvider {
    static var previews: some View {
        VStack {
            W3MTextField("FOoo", text: .constant("Foo"))
            W3MTextField("FOoo", text: .constant("Foo"))
            W3MTextField("FOoo", text: .constant("Foo"), isEditing: .constant(true))
        }
        .padding()
    }
}
