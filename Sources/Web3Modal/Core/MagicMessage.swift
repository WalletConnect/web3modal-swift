import Foundation

class MagicMessage {
    var type: String
    var payload: Any?
    var rt: String?
    var jwt: String?
    var action: String?

    init(type: String, payload: Any? = nil, rt: String? = nil, jwt: String? = nil, action: String? = nil) {
        self.type = type
        self.payload = payload
        self.rt = rt
        self.jwt = jwt
        self.action = action
    }

    func toJson() -> [String: Any] {
        var params: [String: Any] = ["type": type]
        if let payload = payload {
            params["payload"] = payload
        }
        if let rt = rt, !rt.isEmpty {
            params["rt"] = rt
        }
        if let jwt = jwt, !jwt.isEmpty {
            params["jwt"] = jwt
        }
        if let action = action, !action.isEmpty {
            params["action"] = action
        }
        return params
    }

    var toString: String { return "{type: \"\(type)\"}" }

    // @w3m-frame events
    var syncThemeSuccess: Bool { type == "@w3m-frame/SYNC_THEME_SUCCESS" }
    var syncDataSuccess: Bool { type == "@w3m-frame/SYNC_DAPP_DATA_SUCCESS" }
    var connectEmailSuccess: Bool { type == "@w3m-frame/CONNECT_EMAIL_SUCCESS" }
    var connectEmailError: Bool { type == "@w3m-frame/CONNECT_EMAIL_ERROR" }
    var isConnectSuccess: Bool { type == "@w3m-frame/IS_CONNECTED_SUCCESS" }
    var isConnectError: Bool { type == "@w3m-frame/IS_CONNECTED_ERROR" }
    var connectOtpSuccess: Bool { type == "@w3m-frame/CONNECT_OTP_SUCCESS" }
    var connectOtpError: Bool { type == "@w3m-frame/CONNECT_OTP_ERROR" }
    var getUserSuccess: Bool { type == "@w3m-frame/GET_USER_SUCCESS" }
    var getUserError: Bool { type == "@w3m-frame/GET_USER_ERROR" }
    var sessionUpdate: Bool { type == "@w3m-frame/SESSION_UPDATE" }
    var switchNetworkSuccess: Bool { type == "@w3m-frame/SWITCH_NETWORK_SUCCESS" }
    var switchNetworkError: Bool { type == "@w3m-frame/SWITCH_NETWORK_ERROR" }
    var rpcRequestSuccess: Bool { type == "@w3m-frame/RPC_REQUEST_SUCCESS" }
    var rpcRequestError: Bool { type == "@w3m-frame/RPC_REQUEST_ERROR" }
}

class IsConnected: MagicMessage {
    init() {
        super.init(type: "@w3m-app/IS_CONNECTED")
    }
}

class SwitchNetwork: MagicMessage {
    let chainId: String

    init(chainId: String) {
        self.chainId = chainId
        super.init(type: "@w3m-app/SWITCH_NETWORK")
    }

    override var toString: String {
        "{type:'\(type)',payload:{chainId:\(chainId)}}"
    }
}

class ConnectEmail: MagicMessage {
    let email: String
    
    init(email: String) {
        self.email = email
        super.init(type: "@w3m-app/CONNECT_EMAIL")
    }
    
    override var toString: String {
        "{type:'\(type)',payload:{email:'\(email)'}}"
    }
}

class ConnectDevice: MagicMessage {
    init() {
        super.init(type: "@w3m-app/CONNECT_DEVICE")
    }
}

class ConnectOtp: MagicMessage {
    let otp: String
    
    init(otp: String) {
        self.otp = otp
        super.init(type: "@w3m-app/CONNECT_OTP")
    }
    
    override var toString: String {
        "{type:'\(type)',payload:{otp:'\(otp)'}}"
    }
}

class GetUser: MagicMessage {
    
    let chainId: String?

    init(chainId: String?) {
        self.chainId = chainId
        super.init(type: "@w3m-app/GET_USER")
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
        super.init(type: "@w3m-app/SIGN_OUT")
    }
}

class GetChainId: MagicMessage {
    init() {
        super.init(type: "@w3m-app/GET_CHAIN_ID")
    }
}

class RpcRequest: MagicMessage {
    let method: String
    let params: [Any]

    init(method: String, params: [Any]) {
        self.method = method
        self.params = params
        super.init(type: "@w3m-app/RPC_REQUEST")
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
        super.init(type: "@w3m-app/UPDATE_EMAIL")
    }
}

class SyncTheme: MagicMessage {
    var mode: String

    init(mode: String = "light") {
        self.mode = mode
        super.init(type: "@w3m-app/SYNC_THEME")
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
        super.init(type: "@w3m-app/SYNC_DAPP_DATA")
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
