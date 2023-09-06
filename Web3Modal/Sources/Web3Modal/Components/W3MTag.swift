import SwiftUI

struct W3MTag: View {
    enum Variant: CaseIterable, Identifiable {
        case main
        case info
        case success
        case error
        case inProgress
        case warning
        case disabled

        var backgroundColor: Color {
            switch self {
            case .main:
                .Overblue015
            case .info:
                .Overgray010
            case .success:
                .Success100.opacity(0.15)
            case .error:
                .Error100.opacity(0.15)
            case .inProgress:
                Color(red: 0.84, green: 0.85, blue: 0.09).opacity(0.15)
            case .warning:
                .Orange100.opacity(0.15)
            case .disabled:
                .Overgray015.opacity(0.15)
            }
        }
        
        var textColor: Color {
            switch self {
            case .main:
                .Blue100
            case .info:
                .Foreground150
            case .success:
                .Success100
            case .error:
                .Error100
            case .inProgress:
                Color(red: 0.84, green: 0.85, blue: 0.09)
            case .warning:
                .Orange100
            case .disabled:
                .Overgray015
            }
        }
        
        var id: Self {
            return self
        }
    }
    
    @ScaledMetric var scale: CGFloat = 1

    let variant: Variant

    var body: some View {
        Text("TAG TAG")
            .font(.micro700)
            .foregroundColor(variant.textColor)
            .padding(Spacing.xxxs * scale)
            .background(variant.backgroundColor)
            .cornerRadius(Radius.xxxxxs * scale)
    }
}

#if DEBUG
    public struct W3MTagPreviewView: View {
        public init() {}

        public var body: some View {
            VStack {
                ForEach(W3MTag.Variant.allCases) {
                    W3MTag(variant: $0)
                }
            }
            .padding()
            .background(.Overgray002)
        }
    }

    struct W3MTag_Preview: PreviewProvider {
        static var previews: some View {
            W3MTagPreviewView()
                .previewLayout(.sizeThatFits)
        }
    }

#endif
