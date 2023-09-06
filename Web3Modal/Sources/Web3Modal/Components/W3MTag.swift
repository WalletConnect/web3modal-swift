import SwiftUI

struct W3MTag: View {
    enum Variant: String, CaseIterable, Identifiable {
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
                return Color.Overblue015
            case .info:
                return Color.Overgray010
            case .success:
                return Color.Success100.opacity(0.15)
            case .error:
                return Color.Error100.opacity(0.15)
            case .inProgress:
                return Color(red: 0.84, green: 0.85, blue: 0.09).opacity(0.15)
            case .warning:
                return Color.Orange100.opacity(0.15)
            case .disabled:
                return Color.Overgray015.opacity(0.15)
            }
        }
        
        var textColor: Color {
            switch self {
            case .main:
                return Color.Blue100
            case .info:
                return Color.Foreground150
            case .success:
                return Color.Success100
            case .error:
                return Color.Error100
            case .inProgress:
                return Color(red: 0.84, green: 0.85, blue: 0.09)
            case .warning:
                return Color.Orange100
            case .disabled:
                return Color.Overgray015
            }
        }
        
        var id: Self {
            return self
        }
    }

    let title: String
    let variant: Variant
    
    @ScaledMetric var scale: CGFloat = 1

    var body: some View {
        Text(title)
            .textCase(.uppercase)
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
                    W3MTag(title: $0.rawValue, variant: $0)
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
