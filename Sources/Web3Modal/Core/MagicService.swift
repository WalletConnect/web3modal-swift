import Foundation
import WebKit

enum Web3ModalTheme: String {
    case dark
    case light
}

class MagicService {
    private let injectScript = """
    window.addEventListener('message', ({ data }) => {
        window.webkit.messageHandlers.nativeProcess.postMessage(JSON.stringify(data))
    })

    const sendMessage = async (message) => {
        postMessage(message, '*')
    }
    """

    private let url = "https://secure.walletconnect.com"
    private let projectId: String = Web3Modal.config.projectId
//    private let metadata: PairingMetadata

    private let messageHandler: MessageHandler
    private let navigationDelegate: NavigationDelegate
    private let webview: WKWebView
    private let contentController: WKUserContentController

    private var attachedToViewHierarchy = false

    init() {
        self.messageHandler = MessageHandler()
        self.navigationDelegate = NavigationDelegate()

        self.contentController = WKUserContentController()
        contentController.add(messageHandler, name: "nativeProcess")
        contentController.addUserScript(
            WKUserScript(
                source: injectScript,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: false
            )
        )

        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.websiteDataStore = WKWebsiteDataStore.default()
        webConfiguration.userContentController = contentController
        if #available(iOS 14.0, *) {
            webConfiguration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            // Fallback on earlier versions
        }

        self.webview = WKWebView(
            frame: CGRect(x: 0, y: 0, width: 400, height: 400),
            configuration: webConfiguration
        )

        webview.navigationDelegate = navigationDelegate

        if #available(iOS 16.4, *) {
            webview.isInspectable = true
        } else {
            // Fallback on earlier versions
        }

        let url = URL(string: "\(url)/sdk?projectId=\(projectId)")!

        webview.load(
            URLRequest(url: url)
        )
    }

    func attachToViewHierarchy() {
        guard let window = UIApplication.keyWindow else { return }
        window.addSubview(webview)
        window.sendSubviewToBack(webview)

        attachedToViewHierarchy = true
    }

    func connectEmail(email: String) async {
        let message = ConnectEmail(email: email).toString
        await runJavaScript("sendMessage(\(message))")
    }

    func connectDevice() async {
        let message = ConnectDevice().toString
        await runJavaScript("sendMessage(\(message))")
    }

    func connectOtp(otp: String) async {
        // Assuming waitConfirmation is a property you're using to track state
        // waitConfirmation.value = true
        let message = ConnectOtp(otp: otp).toString
        await runJavaScript("sendMessage(\(message))")
    }

    func isConnected() async {
        let message = IsConnected().toString
        await runJavaScript("sendMessage(\(message))")
    }

    func getChainId() async {
        let message = GetChainId().toString
        await runJavaScript("sendMessage(\(message))")
    }

    // Example of a commented-out function, updateEmail, for reference
    // func updateEmail(email: String) async {
    //     await runJavaScript("provider.updateEmail('\(email)')")
    // }

    func syncTheme(theme: Web3ModalTheme?) async {
        guard let mode = theme?.rawValue else { return }
        let message = SyncTheme(mode: mode)
        await runJavaScript("sendMessage(\(message))")
    }

    func syncDappData(metadata: PairingMetadata, sdkVersion: String, projectId: String) async {
        let message = SyncAppData(metadata: metadata, sdkVersion: sdkVersion, projectId: projectId).toString
        await runJavaScript("sendMessage(\(message))")
    }

    func getUser(chainId: String?) async {
        let message = GetUser(chainId: chainId).toString
        await runJavaScript("sendMessage(\(message))")
    }

    func switchNetwork(chainId: String) async {
        let message = SwitchNetwork(chainId: chainId).toString
        await runJavaScript("sendMessage(\(message))")
    }

    func disconnect() async {
        let message = "SignOut()"
        await runJavaScript("sendMessage(\(message))")
    }

    func request(parameters: [String: Any]) async {
        guard let method = parameters["method"] as? String,
              let params = parameters["params"] as? [Any] else { return }
        let message = "RpcRequest(method: \(method), params: \(params))"
        await runJavaScript("sendMessage(\(message))")
        // Handle onApproveTransaction if needed
    }

    @MainActor
    private func runJavaScript(_ script: String) async {
        if !attachedToViewHierarchy {
            attachToViewHierarchy()
        }

        do {
            let result = try await webview.evaluateJavaScript("""
                setTimeout(() => {
                    \(script)
                }, 100)
            """)
        } catch {
            print("JavaScript execution error: \(error)")
        }
    }
}

class MessageHandler: NSObject, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let bodyString = message.body as? String,
              let data = bodyString.data(using: .utf8) else { return }

        do {
            let jsonMessage = try JSONDecoder().decode(MagicMessage.self, from: data)
            // Handle the decoded message
        } catch {
            print("Error decoding message: \(error)")
        }
    }
}

class NavigationDelegate: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {}
}

extension UIApplication {
    static var keyWindow: UIWindow? {
        let allScenes = UIApplication.shared.connectedScenes
        for scene in allScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows where window.isKeyWindow {
                return window
            }
        }
        return nil
    }
}
