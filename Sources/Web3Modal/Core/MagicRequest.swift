import Foundation
import WalletConnectSign

protocol MagicMessageRequest {
    var type: MagicRequest.MessageType { get }
    var toString: String { get }
}

extension MagicMessageRequest {
    var toString: String {
        return #" { "type": "\#(type.rawValue)"} "#
    }
}

enum MagicRequest {

    enum MessageType: String {
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
    
    struct IsConnected: MagicMessageRequest {
        let type: MessageType
        
        init() {
            self.type = MessageType.isConnected
        }
    }

    struct SwitchNetwork: MagicMessageRequest {
        let chainId: String
        let type: MessageType

        init(chainId: String) {
            self.chainId = chainId
            self.type = MessageType.switchNetwork
        }
        
        var toString: String {
            "{type:'\(type.rawValue)',payload:{chainId:\(chainId)}}"
        }
    }

    struct ConnectEmail: MagicMessageRequest {
        let type: MessageType
        let email: String
        
        init(email: String) {
            self.email = email
            self.type = MessageType.connectEmail
        }
        
        var toString: String {
            "{type:'\(type.rawValue)',payload:{email:'\(email)'}}"
        }
    }

    struct ConnectDevice: MagicMessageRequest {
        let type: MessageType
        
        init() {
            self.type = MessageType.connectDevice
        }
    }

    struct ConnectOtp: MagicMessageRequest {
        let otp: String
        let type: MessageType
        
        init(otp: String) {
            self.otp = otp
            self.type = MessageType.connectOtp
        }
        
        var toString: String {
            "{type:'\(type.rawValue)',payload:{otp:'\(otp)'}}"
        }
    }

    struct GetUser: MagicMessageRequest {
        let type: MessageType
        let chainId: String?

        init(chainId: String?) {
            self.chainId = chainId
            self.type = MessageType.getUser
        }

        var toString: String {
            if let chainId {
                return "{type:'\(type.rawValue)',payload:{chainId:\(chainId)}}"
            } else {
                return "{type:'\(type.rawValue)'}"
            }
        }
    }

    struct SignOut: MagicMessageRequest {
        let type: MessageType
        
        init() {
            self.type = MessageType.signOut
        }
    }

    struct GetChainId: MagicMessageRequest {
        let type: MessageType
        
        init() {
            self.type = MessageType.getChainId
        }
    }

    struct RpcRequest: MagicMessageRequest {
        let method: String
        let params: AnyCodable
        let type: MessageType

        init(method: String, params: AnyCodable) {
            self.method = method
            self.params = params
            self.type = MessageType.rpcRequest
        }
        
        // TODO: Properly convert params to string
        var toString: String {
            let m = "method:'\(method)'"
            let p = "" // params.map { "'\($0)'" }.joined(separator: ",")
            return "{type:'\(type.rawValue)',payload:{\(m),params:[\(p)]}}"
        }
    }

    // readonly APP_AWAIT_UPDATE_EMAIL: "@w3m-app/AWAIT_UPDATE_EMAIL";
    struct UpdateEmail: MagicMessageRequest {
        let type: MessageType
        
        init() {
            self.type = MessageType.updateEmail
        }
    }

    struct SyncTheme: MagicMessageRequest {
        var mode: String
        let type: MessageType

        init(mode: String = "light") {
            self.mode = mode
            self.type = MessageType.syncTheme
        }
        
        var toString: String {
            let tm = "themeMode:'\(mode)'"
            return "{type:'\(type.rawValue)',payload:{\(tm)}}"
        }
    }
    
    struct SyncAppData: MagicMessageRequest {
        let metadata: AppMetadata
        let sdkVersion: String
        let projectId: String
        let type: MessageType

        init(metadata: AppMetadata, sdkVersion: String, projectId: String) {
            self.metadata = metadata
            self.sdkVersion = sdkVersion
            self.projectId = projectId
            self.type = MessageType.syncData
        }

        var toString: String {
            let v = "verified: true"
            let p1 = "projectId:'\(projectId)'"
            let p2 = "sdkVersion:'\(sdkVersion)'"
            let m1 = "name:'\(metadata.name)'"
            let m2 = "description:'\(metadata.description)'"
            let m3 = "url:'\(metadata.url)'"
            let m4 = "icons:[\"\(metadata.icons.first ?? "")\"]"
            let p3 = "metadata:{\(m1),\(m2),\(m3),\(m4)}"
            let p = "payload:{\(v),\(p1),\(p2),\(p3)}"
            return "{type:'\(type.rawValue)',\(p)}"
        }
    }
}
