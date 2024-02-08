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
    private let metadata: AppMetadata = Web3Modal.config.metadata

    private let messageHandler: MagicMessageHandler
    private let navigationDelegate: NavigationDelegate
    private let webview: WKWebView
    private let contentController: WKUserContentController

    private var attachedToViewHierarchy = false

    init(router: Router, store: Store = .shared) {
        self.messageHandler = MagicMessageHandler(router: router, store: store)
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

    public func connectEmail(email: String) {
        let message = MagicRequest.ConnectEmail(email: email).toString
        runJavaScript("sendMessage(\(message))")
    }

    func connectDevice() async {
        let message = MagicRequest.ConnectDevice().toString
        runJavaScript("sendMessage(\(message))")
    }

    func connectOtp(otp: String) async {
        // Assuming waitConfirmation is a property you're using to track state
        // waitConfirmation.value = true
        let message = MagicRequest.ConnectOtp(otp: otp).toString
        runJavaScript("sendMessage(\(message))")
    }

    func isConnected() {
        let message = MagicRequest.IsConnected().toString
        runJavaScript("sendMessage(\(message))")
    }

    func getChainId() async {
        let message = MagicRequest.GetChainId().toString
        runJavaScript("sendMessage(\(message))")
    }

    // Example of a commented-out function, updateEmail, for reference
    // func updateEmail(email: String) async {
    //     await runJavaScript("provider.updateEmail('\(email)')")
    // }

    func syncTheme(theme: Web3ModalTheme?) {
        guard let mode = theme?.rawValue else { return }
        let message = MagicRequest.SyncTheme(mode: mode)
        runJavaScript("sendMessage(\(message))")
    }

    func syncDappData(
        metadata: AppMetadata,
        sdkVersion: String,
        projectId: String
    ) async {
        let message = MagicRequest.SyncAppData(metadata: metadata, sdkVersion: sdkVersion, projectId: projectId).toString
        runJavaScript("sendMessage(\(message))")
    }

    func getUser(chainId: String?) {
        let message = MagicRequest.GetUser(chainId: chainId).toString
        runJavaScript("sendMessage(\(message))")
    }

    func switchNetwork(chainId: String) {
        let message = MagicRequest.SwitchNetwork(chainId: chainId).toString
        runJavaScript("sendMessage(\(message))")
    }

    func disconnect() {
        let message = MagicRequest.SignOut()
        runJavaScript("sendMessage(\(message))")
    }

    func request(parameters: [String: Any]) async {
        guard let method = parameters["method"] as? String,
              let params = parameters["params"] as? [Any] else { return }
        let message = "RpcRequest(method: \(method), params: \(params))"
        runJavaScript("sendMessage(\(message))")
        // Handle onApproveTransaction if needed
    }

    private func runJavaScript(_ script: String) {
        if !attachedToViewHierarchy {
            attachToViewHierarchy()
        }

        Task { @MainActor in
            do {
                _ = try await webview.evaluateJavaScript("""
                    setTimeout(() => {
                        \(script)
                    }, 100)
                """)
            } catch {
                print("JavaScript execution error: \(error)")
            }
        }
    }
}

class NavigationDelegate: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {  
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Web3Modal.magicService.isConnected()
        }
    }
}

private extension UIApplication {
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
