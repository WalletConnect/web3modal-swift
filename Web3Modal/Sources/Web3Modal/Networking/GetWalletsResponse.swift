import Foundation

struct GetWalletsResponse: Codable {
    let count: Int
    let data: [Wallet]
}
