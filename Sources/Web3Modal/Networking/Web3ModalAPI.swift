import Foundation
import HTTPClient
import WalletConnectSign

enum Web3ModalAPI: HTTPService {
    struct GetWalletParams {
        let page: Int
        let entries: Int
        let search: String?
        let projectId: String
        let metadata: AppMetadata
        let recommendedIds: [String]
        let excludedIds: [String]
    }
    
    case getWallets(params: GetWalletParams)

    var path: String {
        switch self {
        case .getWallets: return "/getWallets"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getWallets: return .get
        }
    }

    var body: Data? {
        nil
    }

    var queryParameters: [String: String]? {
        switch self {
        case let .getWallets(params):
            return [
                "page": "\(params.page)",
                "entries": "\(params.entries)",
                "search": params.search ?? "",
                "recommendedIds": params.recommendedIds.joined(separator: ","),
                "excludedIds": params.excludedIds.joined(separator: ","),
                "platform": "ios",
            ]
            .compactMapValues { value in
                value.isEmpty ? nil : value
            }
        }
    }

    var scheme: String {
        return "https"
    }

    var additionalHeaderFields: [String: String]? {
        switch self {
        case let .getWallets(params):
            return [
                "x-project-id": params.projectId,
                "x-sdk-version": "ios-3.0.0-alpha.0", // EnvironmentInfo.sdkName,
                "x-sdk-type": "w3m",
                "Referer": params.metadata.name
            ]
        }
    }
}
