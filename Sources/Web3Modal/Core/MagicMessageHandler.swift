import Foundation
import WebKit

class MagicMessageHandler: NSObject, WKScriptMessageHandler {
    
    private let router: Router
    private let store: Store
    
    init(router: Router, store: Store = .shared) {
        self.router = router
        self.store = store
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        print(message.body)
        
        guard
            let bodyString = message.body as? String,
            bodyString.contains("@w3m-frame"),
            let data = bodyString.data(using: .utf8)
        else {
            return
        }

        do {
            let response = try JSONDecoder().decode(MagicMessage.self, from: data)
            handleMagicResponse(response)
        } catch {
            print("Failed decoding Magic response: ", error)
        }
    }
    
    struct Payload: Codable {
        let action: String?
    }
    
    func handleMagicResponse(_ response: MagicMessage) {
        
        let payload = try? response.payload?.get(Payload.self)
        
        switch MagicMessage.MessageType(rawValue: response.type) {
        case .syncThemeSuccess:
            break
        case .syncDataSuccess:
            break
        case .connectEmailSuccess:
            switch payload?.action {
            case "VERIFY_OTP":
                router.setRoute(Router.ConnectingSubpage.otpInput)
            case "VERIFY_DEVICE":
                router.setRoute(Router.ConnectingSubpage.verifyDevice)
            default:
                break
            }
        case .connectEmailError:
            break
        case .isConnectSuccess:
            break
        case .isConnectError:
            break
        case .connectOtpSuccess:
            router.setRoute(Router.ConnectingSubpage.otpResult(true))
        case .connectOtpError:
            router.setRoute(Router.ConnectingSubpage.otpResult(false))
        case .getUserSuccess:
            print("getUserSuccess")
        case .getUserError:
            print("getUserError")
        case .sessionUpdate:
            break
        case .switchNetworkSuccess:
            break
        case .switchNetworkError:
            break
        case .rpcRequestSuccess:
            break
        case .rpcRequestError:
            break
        case .none:
            break
        }
    }
    
}
