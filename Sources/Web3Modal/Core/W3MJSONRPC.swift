import Foundation

public typealias EthAddress = String
public typealias EthTxData = String
public typealias BigInt = String

public enum W3MJSONRPC: Codable {
    case eth_requestAccounts
    
    case personal_sign(
        address: EthAddress,
        message: String
    )
    
    case eth_signTypedData_v3(
        address: EthAddress,
        typedDataJson: JSONString
    )

    case eth_signTypedData_v4(
        address: EthAddress,
        typedDataJson: JSONString
    )
    
    case eth_signTransaction(
        fromAddress: EthAddress,
        toAddress: EthAddress?,
        weiValue: BigInt,
        data: EthTxData,
        nonce: Int?,
        gasPriceInWei: BigInt?,
        maxFeePerGas: BigInt?,
        maxPriorityFeePerGas: BigInt?,
        gasLimit: BigInt?,
        chainId: BigInt
    )
    
    case eth_sendTransaction(
        fromAddress: EthAddress,
        toAddress: EthAddress?,
        weiValue: BigInt,
        data: EthTxData,
        nonce: Int?,
        gasPriceInWei: BigInt?,
        maxFeePerGas: BigInt?,
        maxPriorityFeePerGas: BigInt?,
        gasLimit: BigInt?,
        chainId: BigInt
    )
    
    case wallet_switchEthereumChain(
        chainId: BigInt
    )
    
    case wallet_addEthereumChain(
        chainId: BigInt,
        blockExplorerUrls: [String]?,
        chainName: String?,
        iconUrls: [String]?,
        nativeCurrency: AddChainNativeCurrency?,
        rpcUrls: [String]
    )
    
    case wallet_watchAsset(
        type: String,
        options: WatchAssetOptions
    )
    
    var rawValues: (method: String, params: [String: Any]) {
        let json = try! JSONEncoder().encode(self)
        let dictionary = try! JSONSerialization.jsonObject(with: json) as! [String: [String: Any]]
        
        let method = dictionary.keys.first!
        let params = dictionary[method]!
        return (method, params)
    }
}

public struct AddChainNativeCurrency: Codable {
    let name: String
    let symbol: String
    let decimals: Int
    
    public init(name: String, symbol: String, decimals: Int) {
        self.name = name
        self.symbol = symbol
        self.decimals = decimals
    }
}

public struct WatchAssetOptions: Codable {
    let address: String
    let symbol: String?
    let decimals: Int?
    let image: String?
    
    public init(address: String, symbol: String?, decimals: Int?, image: String?) {
        self.address = address
        self.symbol = symbol
        self.decimals = decimals
        self.image = image
    }
}

public struct JSONString {
    public let rawValue: String
    
    // MARK: Encode
    
    public init?<T: Encodable>(encode value: T) {
        guard let encoded = try? JSONEncoder().encode(value) else { return nil }
        self.init(encodedData: encoded)
    }
    
    public init?(encode value: [String: Any]) {
        guard let encoded = try? JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed) else { return nil }
        self.init(encodedData: encoded)
    }
    
    private init?(encodedData: Data) {
        guard let string = String(data: encodedData, encoding: .utf8) else { return nil }
        self.rawValue = string
    }
    
    // MARK: Decode
    
    private var data: Data? { self.rawValue.data(using: .utf8) }
    
    public func decode() -> Any? {
        guard
            let data = self.data,
            let object = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
        else {
            return nil
        }
        return object
    }
    
    public func decode<T: Decodable>(as type: T.Type) throws -> T? {
        guard let data = self.data else { return nil }
        return try JSONDecoder().decode(type, from: data)
    }
}

extension JSONString: RawRepresentable, Codable, CustomStringConvertible {
    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public var description: String {
        self.rawValue
    }
}
