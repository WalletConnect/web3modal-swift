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
    
    var lastTimeUsed: Date?
    var isInstalled: Bool? = false
    
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
        
        // Decorated
        case lastTimeUsed
        case isInstalled
    }
}

#if DEBUG

extension Wallet {
    static let stubList: [Wallet] = [
        Wallet(
            id: UUID().uuidString,
            name: "Sample Wallet",
            homepage: "https://example.com/cool",
            imageId: "0528ee7e-16d1-4089-21e3-bbfb41933100",
            order: 1,
            mobileLink: "https://sample.com/foo/universal",
            desktopLink: "sampleapp://deeplink",
            webappLink: "https://sample.com/foo/webapp",
            appStore: ""
        ),
        Wallet(
            id: UUID().uuidString,
            name: "Cool Wallet",
            homepage: "https://example.com/cool",
            imageId: "5195e9db-94d8-4579-6f11-ef553be95100",
            order: 2,
            mobileLink: "awsomeapp://",
            desktopLink: "awsomeapp://deeplink",
            webappLink: "https://awesome.com/foo/webapp",
            appStore: ""
        ),
        Wallet(
            id: UUID().uuidString,
            name: "Cool Wallet",
            homepage: "https://example.com/cool",
            imageId: "3913df81-63c2-4413-d60b-8ff83cbed500",
            order: 3,
            mobileLink: "https://cool.com/foo/universal",
            desktopLink: "coolapp://deeplink",
            webappLink: "https://cool.com/foo/webapp",
            appStore: ""
        )
    ]
}

#endif
