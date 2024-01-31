import SwiftUI

struct EnterOTPView: View {
    var body: some View {
        if #available(iOS 15.0, *) {
            OtpView(
                activeIndicatorColor: .blue,
                inactiveIndicatorColor: .gray,
                length: 6,
                doSomething: { otp in
                    print(otp)
                }
            )
        } else {
            EmptyView()
        }
    }
}

#if DEBUG
struct EnterOTPView_Previews: PreviewProvider {
    static var previews: some View {
        EnterOTPView()
    }
}
#endif


@available(iOS 15.0, *)
public struct OtpView:View {
    
    private var activeIndicatorColor: Color
    private var inactiveIndicatorColor: Color
    private let doSomething: (String) -> Void
    private let length: Int
    
    @State private var otpText = ""
    @FocusState private var isKeyboardShowing: Bool
    
    public init(
        activeIndicatorColor: Color,
        inactiveIndicatorColor: Color,
        length: Int,
        doSomething: @escaping (String) -> Void
    ) {
        self.activeIndicatorColor = activeIndicatorColor
        self.inactiveIndicatorColor = inactiveIndicatorColor
        self.length = length
        self.doSomething = doSomething
    }
    public var body: some View {
        HStack(spacing: 0){
            ForEach(0...length-1, id: \.self) { index in
                OTPTextBox(index)
            }
        }.background(content: {
            TextField("", text: $otpText.limit(length))
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .frame(width: 1, height: 1)
                .opacity(0.001)
                .blendMode(.screen)
                .focused($isKeyboardShowing)
                .onChange(of: otpText) { newValue in
                    if newValue.count == length {
                        doSomething(newValue)
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
        ZStack{
            if otpText.count > index {
                let startIndex = otpText.startIndex
                let charIndex = otpText.index(startIndex, offsetBy: index)
                let charToString = String(otpText[charIndex])
                Text(charToString)
            } else {
                Text(" ")
            }
        }
        .frame(width: 45, height: 45)
        .background {
            let status = (isKeyboardShowing && otpText.count == index)
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(status ? activeIndicatorColor : inactiveIndicatorColor)
                .animation(.easeInOut(duration: 0.2), value: status)

        }
        .padding()
    }
}

@available(iOS 13.0, *)
extension Binding where Value == String {
    func limit(_ length: Int)->Self {
        if self.wrappedValue.count > length {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.prefix(length))
            }
        }
        return self
    }
}
