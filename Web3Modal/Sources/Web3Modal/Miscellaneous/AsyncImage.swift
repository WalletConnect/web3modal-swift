import Combine
import SwiftUI

struct AsyncImage<Content>: View where Content: View {
    
    final class Loader: ObservableObject {
        @Published var data: Data? = nil

        private var cancellables = Set<AnyCancellable>()
        private var url: URL?

        init() {}
        
        func setUrl(_ url: URL?) {
            guard
                let url = url,
                url != self.url
            else { return }
            
            self.url = url
            
            var request = URLRequest(url: url)
            
            request.setValue(Web3Modal.config.projectId, forHTTPHeaderField: "x-project-id")
            request.setValue("w3m", forHTTPHeaderField: "x-sdk-type")
            request.setValue("ios-3.0.0-alpha.0", forHTTPHeaderField: "x-sdk-version")
            
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

    @ObservedObject private var imageLoader: Loader = Loader()
    private let conditionalContent: ((Image?) -> Content)?

    init(url: URL?) where Content == Image {
        self.conditionalContent = nil
        imageLoader.setUrl(url)
    }

    init<I, P>(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<I, P>, I: View, P: View {
        self.conditionalContent = { image in
            if let image = image {
                return ViewBuilder.buildEither(first: content(image))
            } else {
                return ViewBuilder.buildEither(second: placeholder())
            }
        }
        imageLoader.setUrl(url)
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
