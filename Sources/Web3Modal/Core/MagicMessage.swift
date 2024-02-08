import Foundation

struct MagicMessage: Decodable {
    enum MessageType: String, Decodable {
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
    
    var type: String
    var payload: AnyCodable?
    var rt: String?
    var jwt: String?
    var action: String?
}
