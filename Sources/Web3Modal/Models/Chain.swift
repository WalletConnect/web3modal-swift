import Foundation

public struct Chain: Identifiable, Hashable {
    struct Token: Hashable {
        var name: String
        var symbol: String
        var decimal: Int
    }
    
    public var id: String {
        "\(chainNamespace):\(chainReference)"
    }

    var chainName: String
    var chainNamespace: String
    var chainReference: String
    var requiredMethods: [String]
    var optionalMethods: [String]
    var events: [String]
    var token: Token
    var rpcUrl: String
    var blockExplorerUrl: String
}

enum EthUtils {
    static let ethRequiredMethods = [String]()
    static let ethOptionalMethods = [String]()
    static let ethEvents = [String]()
}

enum ChainsPresets {
    static let ethToken = Chain.Token(name: "Ether", symbol: "ETH", decimal: 18)

    static let ethChains: [Chain] = [
        Chain(
            chainName: "Ethereum",
            chainNamespace: "eip155",
            chainReference: "1",
            requiredMethods: [],
            optionalMethods: [],
            events: [],
            token: ethToken,
            rpcUrl: "https://cloudflare-eth.com",
            blockExplorerUrl: "https://etherscan.io"
        ),
        Chain(
            chainName: "Arbitrum One",
            chainNamespace: "eip155",
            chainReference: "42161",
            requiredMethods: [],
            optionalMethods: [],
            events: [],
            token: ethToken,
            rpcUrl: "https://arb1.arbitrum.io/rpc",
            blockExplorerUrl: "https://arbiscan.io"
        ),
        Chain(
            chainName: "Polygon",
            chainNamespace: "eip155",
            chainReference: "137",
            requiredMethods: [],
            optionalMethods: [],
            events: [],
            token: .init(name: "MATIC", symbol: "MATIC", decimal: 18),
            rpcUrl: "https://polygon-rpc.com",
            blockExplorerUrl: "https://polygonscan.com"
        ),
        Chain(
            chainName: "Avalanche",
            chainNamespace: "eip155",
            chainReference: "43114",
            requiredMethods: [],
            optionalMethods: [],
            events: [],
            token: .init(name: "Avalanche", symbol: "AVAX", decimal: 18),
            rpcUrl: "https://api.avax.network/ext/bc/C/rpc",
            blockExplorerUrl: "https://snowtrace.io"
        ),
        Chain(
            chainName: "BNB Smart Chain",
            chainNamespace: "eip155",
            chainReference: "56",
            requiredMethods: EthUtils.ethRequiredMethods,
            optionalMethods: EthUtils.ethOptionalMethods,
            events: EthUtils.ethEvents,
            token: .init(name: "BNB",symbol: "BNB",decimal:  18),
            rpcUrl: "https://rpc.ankr.com/bsc",
            blockExplorerUrl: "https://bscscan.com"
        ),
        Chain(
            chainName: "OP Mainnet",
            chainNamespace: "eip155",
            chainReference: "10",
            requiredMethods: EthUtils.ethRequiredMethods,
            optionalMethods: EthUtils.ethOptionalMethods,
            events: EthUtils.ethEvents,
            token: ethToken,
            rpcUrl: "https://mainnet.optimism.io",
            blockExplorerUrl: "https://explorer.optimism.io"
        ),
        Chain(
            chainName: "Gnosis",
            chainNamespace: "eip155",
            chainReference: "100",
            requiredMethods: EthUtils.ethRequiredMethods,
            optionalMethods: EthUtils.ethOptionalMethods,
            events: EthUtils.ethEvents,
            token: .init(name: "Gnosis",symbol: "xDAI",decimal: 18),
            rpcUrl: "https://rpc.gnosischain.com",
            blockExplorerUrl: "https://blockscout.com/xdai/mainnet"
        ),
        Chain(
            chainName: "zkSync Era",
            chainNamespace: "eip155",
            chainReference: "324",
            requiredMethods: EthUtils.ethRequiredMethods,
            optionalMethods: EthUtils.ethOptionalMethods,
            events: EthUtils.ethEvents,
            token: ethToken,
            rpcUrl: "https://mainnet.era.zksync.io",
            blockExplorerUrl: "https://explorer.zksync.io"
        ),
        Chain(
            chainName: "Zora",
            chainNamespace: "eip155",
            chainReference: "7777777",
            requiredMethods: EthUtils.ethRequiredMethods,
            optionalMethods: EthUtils.ethOptionalMethods,
            events: EthUtils.ethEvents,
            token: ethToken,
            rpcUrl: "https://rpc.zora.energy",
            blockExplorerUrl: "https://explorer.zora.energy"
        ),
        Chain(
            chainName: "Base",
            chainNamespace: "eip155",
            chainReference: "8453",
            requiredMethods: EthUtils.ethRequiredMethods,
            optionalMethods: EthUtils.ethOptionalMethods,
            events: EthUtils.ethEvents,
            token: ethToken,
            rpcUrl: "https://mainnet.base.org",
            blockExplorerUrl: "https://basescan.org"
        ),
        Chain(
            chainName: "Celo",
            chainNamespace: "eip155",
            chainReference: "42220",
            requiredMethods: EthUtils.ethRequiredMethods,
            optionalMethods: EthUtils.ethOptionalMethods,
            events: EthUtils.ethEvents,
            token: .init(name: "CELO",symbol: "CELO",decimal: 18),
            rpcUrl: "https://forno.celo.org",
            blockExplorerUrl: "https://explorer.celo.org/mainnet"
        ),
        Chain(
            chainName: "Aurora",
            chainNamespace: "eip155",
            chainReference: "1313161554",
            requiredMethods: [],
            optionalMethods: [],
            events: [],
            token: ethToken,
            rpcUrl: "https://mainnet.aurora.dev",
            blockExplorerUrl: "https://aurorascan.dev"
        )
    ]
}
