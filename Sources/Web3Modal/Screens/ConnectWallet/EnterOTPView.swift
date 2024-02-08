import SwiftUI

struct EnterOTPView: View {
    @EnvironmentObject var store: Store
    
    @State var otp: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Enter the code we sent to \(store.email ?? "undefined")")
                .font(.paragraph500)
                .foregroundColor(.Foreground125)
            
            Spacer().frame(height: Spacing.s)
            
            Text("The code expires in 10 minutes")
                .font(.small400)
                .foregroundColor(.Foreground200)
            
            Spacer().frame(height: Spacing.l)
            
            if store.otpState == .loading {
                DrawingProgressView(
                    shape: .circle,
                    color: .Blue100,
                    lineWidth: 2,
                    duration: 1,
                    isAnimating: .constant(true)
                )
                .frame(width: 32, height: 32)
            } else {
                otpInput()
            }
            
            Spacer().frame(height: Spacing.s)
            
            if store.otpState == .error {
                
                Text("Invalid code")
                    .font(.small400)
                    .foregroundColor(.Error100)
            }
            
            HStack(spacing: Spacing.xxs) {
                Text("Didn't receive it?")
                    .font(.small400)
                    .foregroundColor(.Foreground200)
                   
                Text("Resend code")
                    .font(.small600)
                    .foregroundColor(.Blue100)
            }
        }
        .padding(Spacing.l)
    }
    
    @ViewBuilder
    func otpInput() -> some View {
        if #available(iOS 15.0, *) {
            OtpView(
                length: 6,
                onUpdate: { otp in
                    self.otp = otp
                    Task {
                        await Web3Modal.magicService?.connectOtp(otp: otp)
                    }
                }
            )
        } else {
            EmptyView()
        }
    }
}

#if DEBUG
struct EnterOTPView_Previews: PreviewProvider {
    
    static let store = {
        let store = Store()
        store.email = "radek@walletconnect.com"

        return store
    }()
    
    static var previews: some View {
        EnterOTPView()
            .environmentObject(EnterOTPView_Previews.store)
    }
}
#endif

@available(iOS 15.0, *)
public struct OtpView: View {
    private let onUpdate: (String) -> Void
    private let length: Int
    
    @State private var otpText = ""
    @FocusState private var isKeyboardShowing: Bool
    
    public init(
        length: Int,
        onUpdate: @escaping (String) -> Void
        
    ) {
        self.length = length
        self.onUpdate = onUpdate
    }

    public var body: some View {
        HStack(spacing: Spacing.s) {
            ForEach(0 ... length - 1, id: \.self) { index in
                OTPTextBox(index)
            }
        }
        .background(content: {
            TextField("", text: $otpText)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .frame(width: 100, height: 20)
                .opacity(0.001)
                .blendMode(.screen)
                .focused($isKeyboardShowing)
                .onChange(of: otpText) { newValue in
                    if newValue.count == length {
                        onUpdate(newValue)
                    }
                }
                .onAppear {
                    DispatchQueue.main.async {
                        isKeyboardShowing = true
                    }
                }
        })
        .contentShape(Rectangle())
        .onTapGesture {
            isKeyboardShowing = true
        }
    }
    
    @ViewBuilder
    func OTPTextBox(_ index: Int) -> some View {
        let isEditing = (isKeyboardShowing && otpText.count == index)
        
        ZStack {
            if otpText.count > index {
                let startIndex = otpText.startIndex
                let charIndex = otpText.index(startIndex, offsetBy: index)
                let charToString = String(otpText[charIndex])
                Text(charToString)
            } else {
                Text(isEditing ? "|" : "")
                    .foregroundColor(.Blue100)
            }
        }
        .frame(width: 50, height: 50)
        .foregroundColor(.Foreground100)
        .font(.large500)
        .background(
            RoundedRectangle(cornerRadius: Radius.xs)
                .fill(isEditing ? .GrayGlass010 : .GrayGlass005)
        )
        .background(
            RoundedRectangle(cornerRadius: Radius.xs)
                .stroke(.GrayGlass005, lineWidth: 1)
        )
        .backport.overlay {
            if isEditing {
                ZStack {
                    RoundedRectangle(cornerRadius: Radius.xs)
                        .inset(by: -4)
                        .fill(Color(red: 0.2, green: 0.59, blue: 1).opacity(0.2))
                        
                    RoundedRectangle(cornerRadius: Radius.xs)
                        .blendMode(.destinationOut)
                        
                    RoundedRectangle(cornerRadius: Radius.xs)
                        .stroke(Color.Blue100, lineWidth: 1)
                }
                .compositingGroup()
            }
        }
    }
}
