enum AnalyticsEvent: Equatable {
    case MODAL_LOADED // ⚠️ when to fire?
    case MODAL_OPEN(connected: Bool) // ✅
    case MODAL_CLOSE(connected: Bool) // ✅
    case CLICK_ALL_WALLETS // ✅
    case SELECT_WALLET(wallet: Wallet) // ✅
    case CLICK_NETWORKS // ✅
    case OPEN_ACTIVITY_VIEW // ❌ not implemented
    case SWITCH_NETWORK(network: Chain) // ☑️
    case CONNECT_SUCCESS(method: Method) // ☑️
    case CONNECT_ERROR(errorType: ErrorType) // ☑️
    case DISCONNECT_SUCCESS // ☑️
    case DISCONNECT_ERROR // ☑️
    case CLICK_WALLET_HELP // ☑️
    case CLICK_NETWORK_HELP // ☑️
    case CLICK_GET_WALLET // ☑️

    enum ErrorType: Equatable {
        case timeout
        case rejected
        case arbitrary(String)
    }
    
    enum Method: String {
        case qr = "QR"
        case mobileLinks = "mobile-links"
        case external = "external"
        case email = "email"
    }
}
