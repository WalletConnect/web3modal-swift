import Foundation

enum BlockchainAPI: HTTPService {
    struct GetIdentityParams {
        let address: String
        let chainId: String
        let projectId: String
    }
    
    case getIdentity(params: GetIdentityParams)

    var path: String {
        switch self {
        case let .getIdentity(params): return "/v1/identity/\(params.address)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getIdentity: return .get
        }
    }

    var body: Data? {
        nil
    }

    var queryParameters: [String: String]? {
        switch self {
        case let .getIdentity(params):
            return [
                "projectId": params.projectId,
                "chainId": params.chainId,
            ]
        }
    }

    var scheme: String {
        return "https"
    }

    var additionalHeaderFields: [String: String]? {
        nil
    }
}
