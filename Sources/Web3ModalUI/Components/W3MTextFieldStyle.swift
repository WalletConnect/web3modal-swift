import SwiftUI

public struct W3MTextField: View {
    var titleKey: LocalizedStringKey
    @Binding var text: String

    /// Whether the user is focused on this `TextField`.
    @State private var isEditing: Bool = false

    public init(_ titleKey: LocalizedStringKey, text: Binding<String>) {
        self.titleKey = titleKey
        self._text = text
    }

    public var body: some View {
        HStack(spacing: Spacing.xs) {
            Image.Medium.magnifier
                .foregroundColor(.Overgray030)

            TextField(titleKey, text: $text, onEditingChanged: { isEditing = $0 })
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
                RoundedRectangle(cornerRadius: Radius.xxs)
                    .inset(by: 5)
                .stroke(Color.Blue100, lineWidth: 1)
            )
        }
    }
}

struct W3MTextFieldStylePreview: PreviewProvider {
    static var previews: some View {
        VStack {
            W3MTextField("FOoo", text: .constant("Foo"))
            W3MTextField("FOoo", text: .constant("Foo"))
        }
        .padding()
    }
}
