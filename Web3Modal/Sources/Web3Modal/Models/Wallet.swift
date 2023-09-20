import Foundation

struct Wallet: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let homepage: String
    let imageId: String
    let order: Int
    let mobileLink: String?
    let desktopLink: String?
    let webappLink: String?
    let appStore: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case homepage
        case imageId = "image_id"
        case order
        case mobileLink = "mobile_link"
        case desktopLink = "desktop_link"
        case webappLink = "webapp_link"
        case appStore = "app_store"
    }
}


#if DEBUG

extension Wallet {
    static let stubList: [Wallet] = [
        Wallet(
            id: UUID().uuidString,
            name: "Sample Wallet",
            homepage: "https://example.com/cool",
            imageId: UUID().uuidString, order: 3,
            mobileLink: "https://sample.com/foo/universal",
            desktopLink: "sampleapp://deeplink",
            webappLink: "https://sample.com/foo/webapp",
            appStore: ""
        ),
        Wallet(
            id: UUID().uuidString,
            name: "Cool Wallet",
            homepage: "https://example.com/cool",
            imageId: UUID().uuidString, order: 3,
            mobileLink: "awsomeapp://",
            desktopLink: "awsomeapp://deeplink",
            webappLink: "https://awesome.com/foo/webapp",
            appStore: ""
        ),
        Wallet(
            id: UUID().uuidString,
            name: "Cool Wallet",
            homepage: "https://example.com/cool",
            imageId: UUID().uuidString, order: 3,
            mobileLink: "https://cool.com/foo/universal",
            desktopLink: "coolapp://deeplink",
            webappLink: "https://cool.com/foo/webapp",
            appStore: ""
        )
    ]
}

#endif
