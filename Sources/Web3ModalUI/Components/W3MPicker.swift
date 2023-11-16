import SwiftUI

public struct W3MPicker<Data, Content>: View where Data: Hashable, Content: View {
    let sources: [Data]
    let selection: Data?
    let itemBuilder: (Data) -> Content
    
    @State private var backgroundColor: Color = Color.black.opacity(0.05)
    
    public func pickerBackgroundColor(_ color: Color) -> W3MPicker {
        var view = self
        view._backgroundColor = State(initialValue: color)
        return view
    }
    
    @State private var cornerRadius: CGFloat?
    
    public func cornerRadius(_ cornerRadius: CGFloat) -> W3MPicker {
        var view = self
        view._cornerRadius = State(initialValue: cornerRadius)
        return view
    }
    
    @State private var borderColor: Color?
    
    public func borderColor(_ borderColor: Color) -> W3MPicker {
        var view = self
        view._borderColor = State(initialValue: borderColor)
        return view
    }
    
    @State private var borderWidth: CGFloat?
    
    public func borderWidth(_ borderWidth: CGFloat) -> W3MPicker {
        var view = self
        view._borderWidth = State(initialValue: borderWidth)
        return view
    }
    
    private var customIndicator: AnyView?
    
    public init(
        _ sources: [Data],
        selection: Data?,
        @ViewBuilder itemBuilder: @escaping (Data) -> Content
    ) {
        self.sources = sources
        self.selection = selection
        self.itemBuilder = itemBuilder
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            if let selection = selection, let selectedIdx = sources.firstIndex(of: selection) {
                
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: cornerRadius ?? 6.0)
                        .stroke(borderColor ?? .clear, lineWidth: borderWidth ?? 0)
                        .foregroundColor(.accentColor)
                        .frame(width: geo.size.width / CGFloat(sources.count))
                        .animation(.spring().speed(1.5), value: selection)
                        .offset(x: geo.size.width / CGFloat(sources.count) * CGFloat(selectedIdx), y: 0)
                }.frame(height: 28)
            }
            
            HStack(spacing: 0) {
                ForEach(sources, id: \.self) { item in
                    itemBuilder(item)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: cornerRadius ?? 6.0)
                .fill(backgroundColor)
                .padding(-3)
        )
    }
}

struct PreviewWeb3ModalPicker: View {
    
    enum Platform: String, CaseIterable {
        case native
        case browser
    }
    
    @State private var selectedItem: Platform? = .native
    
    var body: some View {
        W3MPicker(
            Platform.allCases,
            selection: selectedItem
        ) { item in
                
            HStack {
                item == .native ? Image.Bold.mobile : Image.Bold.web
                Text(item.rawValue.capitalized)
            }
            .font(.small600)
            .multilineTextAlignment(.center)
            .foregroundColor(selectedItem == item ? .Foreground100 : .Foreground200)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.15)) {
                    selectedItem = item
                }
            }
        }
        .pickerBackgroundColor(.Background100)
        .cornerRadius(20)
        .borderWidth(1)
        .borderColor(Color.Overgray005)
        .accentColor(Color.Overgray005)
        .frame(maxWidth: 250)
        .padding()
    }
}

struct Web3ModalPicker_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWeb3ModalPicker()
    }
}
