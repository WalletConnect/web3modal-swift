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
    
        
        guard
            let bodyString = message.body as? String,
            bodyString.contains("@w3m-frame") || bodyString.contains("@w3m-app"),
            let data = bodyString.data(using: .utf8)
        else {
            return
        }

        print(message.body)
        
        do {
            let response = try JSONDecoder().decode(MagicMessage.self, from: data)
            handleMagicResponse(response)
        } catch {
            print("Failed decoding Magic response: ", error)
        }
    }
    
    
    func handleMagicResponse(_ response: MagicMessage) {

        
        switch MagicMessage.MessageType(rawValue: response.type) {
        case .syncThemeSuccess:
            break
        case .syncDataSuccess:
            break
        case .connectEmailSuccess:
            
            struct Payload: Codable {
                let action: String?
            }
            
            let payload = try? response.payload?.get(Payload.self)
            
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
            
            struct Payload: Codable {
                let isConnected: Bool?
            }
            
            let payload = try? response.payload?.get(Payload.self)
            
            if payload?.isConnected == true {
                Web3Modal.magicService.getUser(chainId: store.selectedChain?.id)
            }
        case .isConnectError:
            
            print("No magic connection")
        case .connectOtpSuccess:
            store.otpState = .success
            
            Web3Modal.magicService.getUser(chainId: store.selectedChain?.id)
        case .connectOtpError:
            store.otpState = .error
        case .getUserSuccess:
            
            struct Payload: Codable {
                let chainId: Int?
                let address: String?
            }
            
            guard
                let payload = try? response.payload?.get(Payload.self),
                let address = payload.address,
                let chainId = payload.chainId,
                let blockChain = Blockchain("eip155:\(chainId)")
            else {
                return
            }
            
            store.account = .init(address: address, chain: blockChain)
            store.connectedWith = .magic
            router.setRoute(Router.AccountSubpage.profile)
        case .getUserError:
            print("getUserError")
        case .sessionUpdate:
            break
        case .switchNetworkSuccess:
            
            struct Payload: Codable {
                let chainId: Int?
                let address: String?
            }
            
            guard
                let payload = try? response.payload?.get(Payload.self),
                let chainId = payload.chainId,
                let blockChain = Blockchain("eip155:\(chainId)")
            else {
                return
            }
            
            store.selectedChain = ChainPresets.ethChains.first(where: { $0.id == blockChain.absoluteString })
            router.setRoute(Router.AccountSubpage.profile)
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
