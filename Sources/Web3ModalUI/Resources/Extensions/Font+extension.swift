import SwiftUI

public extension Font {
    static var large500: Font = .system(size: 20.0, weight: .regular)
    static var large600: Font = .system(size: 20.0, weight: .medium)
    static var large700: Font = .system(size: 20.0, weight: .semibold)
    static var micro600: Font = .system(size: 10.0, weight: .medium)
    static var micro700: Font = .system(size: 10.0, weight: .semibold)
    static var paragraph500: Font = .system(size: 16.0, weight: .regular)
    static var paragraph600: Font = .system(size: 16.0, weight: .medium)
    static var paragraph700: Font = .system(size: 16.0, weight: .semibold)
    static var small500: Font = .system(size: 14.0, weight: .regular)
    static var small600: Font = .system(size: 14.0, weight: .medium)
    static var tiny500: Font = .system(size: 12.0, weight: .regular)
    static var tiny600: Font = .system(size: 12.0, weight: .medium)
    static var title500: Font = .system(size: 24.0, weight: .regular)
    static var title600: Font = .system(size: 24.0, weight: .medium)
    static var title700: Font = .system(size: 24.0, weight: .semibold)
}

struct FontPreviews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
            Text("large500").font(.large500)
            Text("large600").font(.large600)
            Text("large700").font(.large700)
            Text("micro600").font(.micro600)
            Text("micro700").font(.micro700)
            Text("paragraph500").font(.paragraph500)
            Text("paragraph600").font(.paragraph600)
            Text("paragraph700").font(.paragraph700)
            Text("small500").font(.small500)
            Text("small600").font(.small600)
            Text("tiny500").font(.tiny500)
            Text("tiny600").font(.tiny600)
            Text("title500").font(.title500)
            Text("title600").font(.title600)
            Text("title700").font(.title700)
        }
    }
}
