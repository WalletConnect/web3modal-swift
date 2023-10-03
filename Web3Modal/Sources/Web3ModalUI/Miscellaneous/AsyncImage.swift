import Combine
import SwiftUI

struct AsyncImage<Content>: View where Content: View {
    @StateObject fileprivate var loader: ImageLoader
    @ViewBuilder private var content: (AsyncImagePhase) -> Content

    init(
        url: URL?,
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        _loader = .init(wrappedValue: ImageLoader(url: url))
        self.content = content
    }

    init<I, P>(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where
        Content == _ConditionalContent<I, P>,
        I: View,
        P: View
    {
        self.init(url: url) { phase in
            switch phase {
            case .success(let image):
                content(image)
            case .empty, .failure:
                placeholder()
            }
        }
    }

    var body: some View {
        content(loader.phase).onAppear {
            loader.load()
        }
    }
}

enum ImageSource {
    case remote(url: URL?)
    case local(name: String)
    case captured(image: UIImage)
}

enum AsyncImagePhase {
    case empty
    case success(Image)
    case failure(Error)
}

public class ImageLoader: ObservableObject {
    
    public static var headers: [String: String] = [:]
    
    private static let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        let session = URLSession(configuration: configuration)
        return session
    }()

    private enum LoaderError: Swift.Error {
        case missingURL
        case failedToDecodeFromData
    }

    @Published var phase = AsyncImagePhase.empty
    private var subscriptions: [AnyCancellable] = []

    private let url: URL?

    init(url: URL?) {
        self.url = url
    }

    deinit {
        cancel()
    }

    func load() {
        guard let url = url else {
            phase = .failure(LoaderError.missingURL)
            return
        }

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ImageLoader.headers
        
        ImageLoader.session.dataTaskPublisher(for: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.phase = .failure(error)
                }
            }, receiveValue: {
                if let image = UIImage(data: $0.data) {
                    self.phase = .success(Image(uiImage: image))
                } else {
                    self.phase = .failure(LoaderError.failedToDecodeFromData)
                }
            })
            .store(in: &subscriptions)
    }

    func cancel() {
        subscriptions.forEach { $0.cancel() }
    }
}
