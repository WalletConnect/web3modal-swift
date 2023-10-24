import SwiftUI

public struct Toast: Equatable {
    let style: ToastStyle
    let message: String
    var duration: Double = 3
    var width: Double = .infinity
    
    public init(style: ToastStyle, message: String, duration: Double = 3, width: Double = .infinity) {
        self.style = style
        self.message = message
        self.duration = duration
        self.width = width
    }
}

public enum ToastStyle {
    case error
    case warning
    case success
    case info

    var themeColor: Color {
        switch self {
        case .error: return Color.Error100
        case .warning: return Color.orange
        case .info: return Color.Indigo100
        case .success: return Color.green
        }
    }
  
    var icon: Image {
        switch self {
        case .info: return Image(systemName: "info.circle.fill")
        case .warning: return Image(systemName: "exclamationmark.triangle.fill")
        case .success: return Image(systemName: "checkmark.circle.fill")
        case .error: return Image(systemName: "xmark.circle.fill")
        }
    }
}

struct ToastView: View {
    var style: ToastStyle
    var message: String

    var onCancelTapped: () -> Void
  
    public var body: some View {
        HStack(alignment: .center, spacing: Spacing.xs) {
            style.icon
                .foregroundColor(style.themeColor)
            Text(message)
                .font(.paragraph500)
                .foregroundColor(.Foreground100)
      
        }
        .padding()
        .background(Color.Background175)
        .cornerRadius(Radius.l)
        .overlay {
            RoundedRectangle(cornerRadius: Radius.l)
                .stroke(.GrayGlass005, lineWidth: 1)
        }
        .padding(.horizontal, 16)
    }
}

public struct ToastModifier: ViewModifier {
    @Binding var toast: Toast?
    @State private var workItem: DispatchWorkItem?
  
    public func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    mainToastView()
                        .padding()
                }
                .animation(.spring(), value: toast)
            )
            .onChange(of: toast) { _ in
                showToast()
            }
    }
  
    @ViewBuilder func mainToastView() -> some View {
        if let toast = toast {
            VStack {
                ToastView(
                    style: toast.style,
                    message: toast.message
                ) {
                    dismissToast()
                }
                
                Spacer()
                    .allowsHitTesting(false)
            }
        }
    }
  
    private func showToast() {
        guard let toast = toast else { return }
    
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light)
            .impactOccurred()
        #endif
        
        if toast.duration > 0 {
            workItem?.cancel()
      
            let task = DispatchWorkItem {
                dismissToast()
            }
      
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
        }
    }
  
    private func dismissToast() {
        withAnimation {
            toast = nil
        }
    
        workItem?.cancel()
        workItem = nil
    }
}

public extension View {
    func toastView(toast: Binding<Toast?>) -> some View {
        modifier(ToastModifier(toast: toast))
    }
}

struct ToastView_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
                .frame(maxWidth: .infinity)
            Text("Hello World").foregroundColor(.Foreground100)
            Spacer()
                .frame(maxWidth: .infinity)
        }
        .background(Color.Overgray015)
        .frame(width: 300, height: 250)
        .toastView(toast: .constant(Toast(style: .info, message: "Hello World")))
    }
}
