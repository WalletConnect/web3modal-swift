//

import Foundation

enum EnvironmentInfo {
    
    static var sdkVersion: String {
        "swift-\(packageVersion)"
    }
    
    static var packageVersion: String {
        guard
            let fileURL = Bundle.coreModule.url(forResource: "PackageConfig", withExtension: "json"),
            let data = try? Data(contentsOf: fileURL),
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let version = jsonObject["version"] as? String
        else {
            return "undefined"
        }
        
        return version
    }
}
