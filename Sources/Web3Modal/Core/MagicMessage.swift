import Foundation


protocol MagicMessageType: Codable {
    var rawValue: String { get }
}

enum MagicMessageResponseType: String, MagicMessageType, Codable {
    case syncThemeSuccess = "@w3m-frame/SYNC_THEME_SUCCESS"
    case syncDataSuccess = "@w3m-frame/SYNC_DAPP_DATA_SUCCESS"
    case connectEmailSuccess = "@w3m-frame/CONNECT_EMAIL_SUCCESS"
    case connectEmailError = "@w3m-frame/CONNECT_EMAIL_ERROR"
    case isConnectSuccess = "@w3m-frame/IS_CONNECTED_SUCCESS"
    case isConnectError = "@w3m-frame/IS_CONNECTED_ERROR"
    case connectOtpSuccess = "@w3m-frame/CONNECT_OTP_SUCCESS"
    case connectOtpError = "@w3m-frame/CONNECT_OTP_ERROR"
    case getUserSuccess = "@w3m-frame/GET_USER_SUCCESS"
    case getUserError = "@w3m-frame/GET_USER_ERROR"
    case sessionUpdate = "@w3m-frame/SESSION_UPDATE"
    case switchNetworkSuccess = "@w3m-frame/SWITCH_NETWORK_SUCCESS"
    case switchNetworkError = "@w3m-frame/SWITCH_NETWORK_ERROR"
    case rpcRequestSuccess = "@w3m-frame/RPC_REQUEST_SUCCESS"
    case rpcRequestError = "@w3m-frame/RPC_REQUEST_ERROR"
}

enum MagicMessageRequestType: String, MagicMessageType, Codable {
    case syncTheme = "@w3m-app/SYNC_THEME"
    case syncData = "@w3m-app/SYNC_DAPP_DATA"
    case connectEmail = "@w3m-app/CONNECT_EMAIL"
    case connectDevice = "@w3m-app/CONNECT_DEVICE"
    case isConnected = "@w3m-app/IS_CONNECTED"
    case connectOtp = "@w3m-app/CONNECT_OTP"
    case switchNetwork = "@w3m-app/SWITCH_NETWORK"
    case rpcRequest = "@w3m-app/RPC_REQUEST"
    case signOut = "@w3m-app/SIGN_OUT"
    case getUser = "@w3m-app/GET_USER"
    case getChainId = "@w3m-app/GET_CHAIN_ID"
    case updateEmail = "@w3m-app/UPDATE_EMAIL"
}

class MagicMessage: Decodable {
    var type: MagicMessageType
    var payload: AnyCodable?
    var rt: String?
    var jwt: String?
    var action: String?
    
    enum CodingKeys: CodingKey {
        case type
        case payload
        case rt
        case jwt
        case action
    }

    init(type: MagicMessageType, payload: AnyCodable? = nil, rt: String? = nil, jwt: String? = nil, action: String? = nil) {
        self.type = type
        self.payload = payload
        self.rt = rt
        self.jwt = jwt
        self.action = action
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(MagicMessageResponseType.self, forKey: .type)
        self.payload = try container.decodeIfPresent(AnyCodable.self, forKey: .payload)
        self.rt = try container.decodeIfPresent(String.self, forKey: .rt)
        self.jwt = try container.decodeIfPresent(String.self, forKey: .jwt)
        self.action = try container.decodeIfPresent(String.self, forKey: .action)
    }

    var toString: String { return "{type: \"\(type)\"}" }
}

class IsConnected: MagicMessage {
    init() {
        super.init(type: MagicMessageRequestType.isConnected)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}

class SwitchNetwork: MagicMessage {
    let chainId: String

    init(chainId: String) {
        self.chainId = chainId
        super.init(type: MagicMessageRequestType.switchNetwork)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
    }
    
    override var toString: String {
        "{type:'\(type.rawValue)',payload:{chainId:\(chainId)}}"
    }
}

class ConnectEmail: MagicMessage {
    let email: String
    
    init(email: String) {
        self.email = email
        super.init(type: MagicMessageRequestType.connectEmail)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    override var toString: String {
        "{type:'\(type)',payload:{email:'\(email)'}}"
    }
}

class ConnectDevice: MagicMessage {
    init() {
        super.init(type: MagicMessageRequestType.connectDevice)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}

class ConnectOtp: MagicMessage {
    let otp: String
    
    init(otp: String) {
        self.otp = otp
        super.init(type: MagicMessageRequestType.connectOtp)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    override var toString: String {
        "{type:'\(type)',payload:{otp:'\(otp)'}}"
    }
}

class GetUser: MagicMessage {
    
    let chainId: String?

    init(chainId: String?) {
        self.chainId = chainId
        super.init(type: MagicMessageRequestType.getUser)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    override var toString: String {
        if let chainId {
            return "{type:'\(type)',payload:{chainId:\(chainId)}}"
        } else {
            return "{type:'\(type)'}"
        }
    }
}

class SignOut: MagicMessage {
    init() {
        super.init(type: MagicMessageRequestType.signOut)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}

class GetChainId: MagicMessage {
    init() {
        super.init(type: MagicMessageRequestType.getChainId)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}

class RpcRequest: MagicMessage {
    let method: String
    let params: [Any]

    init(method: String, params: [Any]) {
        self.method = method
        self.params = params
        super.init(type: MagicMessageRequestType.rpcRequest)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    override var toString: String {
        let m = "method:'\(method)'"
        let p = params.map { "'\($0)'" }.joined(separator: ",")
        return "{type:'\(type)',payload:{\(m),params:[\(p)]}}"
    }
}

// readonly APP_AWAIT_UPDATE_EMAIL: "@w3m-app/AWAIT_UPDATE_EMAIL";
class UpdateEmail: MagicMessage {
    init() {
        super.init(type: MagicMessageRequestType.updateEmail)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}

class SyncTheme: MagicMessage {
    var mode: String

    init(mode: String = "light") {
        self.mode = mode
        super.init(type: MagicMessageRequestType.syncTheme)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    override var toString: String {
        let tm = "themeMode:'\(mode)'"
        return "{type:'\(type)',payload:{\(tm)}}"
    }
}

struct PairingMetadata {
    let name: String
    let description: String
    let url: String
    let icons: [String]
}

class SyncAppData: MagicMessage {
    let metadata: PairingMetadata
    let sdkVersion: String
    let projectId: String

    init(metadata: PairingMetadata, sdkVersion: String, projectId: String) {
        self.metadata = metadata
        self.sdkVersion = sdkVersion
        self.projectId = projectId
        super.init(type: MagicMessageRequestType.syncData)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    override var toString: String {
        let v = "verified: true"
        let p1 = "projectId:'\(projectId)'"
        let p2 = "sdkVersion:'\(sdkVersion)'"
        let m1 = "name:'\(metadata.name)'"
        let m2 = "description:'\(metadata.description)'"
        let m3 = "url:'\(metadata.url)'"
        let m4 = "icons:[\"\(metadata.icons.first ?? "")\"]"
        let p3 = "metadata:{\(m1),\(m2),\(m3),\(m4)}"
        let p = "payload:{\(v),\(p1),\(p2),\(p3)}"
        return "{type:'\(type)',\(p)}"
    }
}
