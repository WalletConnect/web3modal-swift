import SwiftUI

struct W3MAllWalletsImage: View {
 
    @ScaledMetric var scale: CGFloat = 1
    
    var images: [WalletImage]

    var body: some View {
        VStack(spacing: 2 * scale) {
            HStack(spacing: 2 * scale) {
                walletImage(images[safe: 0])
                walletImage(images[safe: 1])
            }
            .padding(.horizontal, 3.5 * scale)

            HStack(spacing: 2 * scale) {
                walletImage(images[safe: 2])
                walletImage(images[safe: 3])
            }
            .padding(.horizontal, 3.5 * scale)
        }
        .padding(.vertical, 3.5 * scale)
        .frame(width: 40 * scale, height: 40 * scale)
        .cornerRadius(Radius.xxxs * scale)
        .overlay {
            RoundedRectangle(cornerRadius: Radius.xxxs)
                .strokeBorder(.Overgray010, lineWidth: 0.5 * scale)
                .background(RoundedRectangle(cornerRadius: Radius.xxxs).fill(.Overgray005))
        }
    }

    @ViewBuilder
    func walletImage(_ image: WalletImage?) -> some View {
        AsyncImage(url: image == nil ? .none : URL(string: image!.url)) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            Image.Wallet
                .resizable()
                .scaledToFit()
                .padding(3 * scale)
        }
        .frame(width: 15 * scale, height: 15 * scale)
        .cornerRadius(Radius.xxxxxs)
        .overlay {
            RoundedRectangle(cornerRadius: Radius.xxxxxs)
                .strokeBorder(.Overgray010, lineWidth: 0.2)
        }
    }
}

#if DEBUG
    public struct W3MAllWalletsImageView: View {
        public init() {}

        public var body: some View {
            VStack {
                W3MAllWalletsImage(images: [
                    .init(url: "https://api.web3modal.com/getWalletImage/5195e9db-94d8-4579-6f11-ef553be95100", walletName: "Metamask"),
                    .init(url: "https://api.web3modal.com/getWalletImage/0528ee7e-16d1-4089-21e3-bbfb41933100", walletName: "Trust"),
                    .init(url: "https://api.web3modal.com/getWalletImage/3913df81-63c2-4413-d60b-8ff83cbed500", walletName: "Safe"),
                    .init(url: "https://api.web3modal.com/getWalletImage/7a33d7f1-3d12-4b5c-f3ee-5cd83cb1b500", walletName: "Rainbow"),
                ])
            }
            .padding()
            .background(.Overgray002)
        }
    }

    struct W3MAllWalletsImage_Previews: PreviewProvider {
        static var previews: some View {
            W3MAllWalletsImageView()
                .previewLayout(.sizeThatFits)
        }
    }

#endif

import Combine
import SwiftUI

struct AsyncImage<Content>: View where Content: View {
    final class Loader: ObservableObject {
        @Published var data: Data? = nil

        private var cancellables = Set<AnyCancellable>()

        init(_ url: URL?) {
            guard let url = url else { return }

            var request = URLRequest(url: url)
            request.addValue("ios-w3m-alpha", forHTTPHeaderField: "x-sdk-version")
            request.addValue("w3m", forHTTPHeaderField: "x-sdk-type")
            request.addValue("2a2a5978a58aad734d13a2d194ec469a", forHTTPHeaderField: "x-project-id")

            URLSession.shared.dataTaskPublisher(for: request)
                .map(\.data)
                .map { $0 as Data? }
                .replaceError(with: nil)
                .receive(on: RunLoop.main)
                .sink(receiveValue: { data in
                    withAnimation {
                        self.data = data
                    }
                })
                .store(in: &cancellables)
        }
    }

    @ObservedObject private var imageLoader: Loader
    private let conditionalContent: ((Image?) -> Content)?

    init(url: URL?) where Content == Image {
        self.imageLoader = Loader(url)
        self.conditionalContent = nil
    }

    init<I, P>(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<I, P>, I: View, P: View {
        self.imageLoader = Loader(url)
        self.conditionalContent = { image in
            if let image = image {
                return ViewBuilder.buildEither(first: content(image))
            } else {
                return ViewBuilder.buildEither(second: placeholder())
            }
        }
    }

    private var image: Image? {
        imageLoader.data
            .flatMap {
                #if canImport(UIKit)
                    UIImage(data: $0)
                #elseif canImport(AppKit)
                    NSImage(data: $0)
                #endif
            }
            .flatMap(Image.init)
    }

    var body: some View {
        if let conditionalContent = conditionalContent {
            conditionalContent(image)
        } else if let image = image {
            image
        }
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
