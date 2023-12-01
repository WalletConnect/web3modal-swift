import Foundation

struct GetWalletsResponse: Codable {
    let count: Int
    let data: [WalletDTO]
}

struct GetIosDataResponse: Codable {
    let count: Int
    let data: [WalletMetadata]
    
    struct WalletMetadata: Codable {
        let id: String
        let ios_schema: String
    }
}
