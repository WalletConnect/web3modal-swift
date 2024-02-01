require "json"

package = JSON.parse(File.read(File.join(__dir__, "Sources/Web3Modal/PackageConfig.json")))

Pod::Spec.new do |spec|
    spec.name         = "Web3Modal"
    spec.version      = "#{package["version"]}"
    spec.summary      = "A single Web3 provider solution for all Wallets"
    spec.description  = "Your on-ramp to web3 multichain. Web3Modal is a versatile library that makes it super easy to connect users with your Dapp and start interacting with the blockchain."
    spec.screenshots  = "https://web3modal.com/images/hero-banner.png"
    spec.homepage     = "https://web3modal.com/"
    spec.license      = { :type => 'Apache-2.0', :file => 'LICENSE' }
    spec.authors      = "WalletConnect, Inc."
    spec.social_media_url = "https://twitter.com/WalletConnect"
    spec.platform      = :ios, "13.0"
    spec.swift_version = "5.9"

    spec.source       = { :git => "https://github.com/WalletConnect/web3modal-swift.git", :tag => "#{spec.version}" }

    spec.pod_target_xcconfig = {
        'OTHER_SWIFT_FLAGS' => '-DCocoaPods'
    }

    # ――― Sub Specs ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

    spec.default_subspecs = 'Web3Modal'

    spec.subspec 'Web3Modal' do |ss|
        ss.source_files = 'Sources/Web3Modal/**/*.{h,m,swift}'
        ss.dependency 'Web3Modal/Web3ModalUI'
        ss.dependency 'Web3Modal/Web3ModalBackport'
        ss.dependency 'WalletConnectSwiftV2/WalletConnectSign', '~> 1.9.0'
        ss.dependency 'DSF_QRCode', '~> 16.1.1'
        ss.dependency 'CoinbaseWalletSDK', '~> 1.0.4'
        ss.resource_bundles = { 'Web3Modal' => ['Sources/Web3Modal/Resources/*'] }
    end

    spec.subspec 'Web3ModalUI' do |ss|
        ss.source_files = 'Sources/Web3ModalUI/**/*.{h,m,swift}'
        ss.dependency 'Web3Modal/Web3ModalBackport'
        ss.resource_bundles = { 'Web3ModalUI' => ['Sources/Web3ModalUI/Resources/*'] }
    end
    
    spec.subspec 'Web3ModalBackport' do |ss|
        ss.source_files = 'Sources/Web3ModalBackport/**/*.{h,m,swift}'
    end
end
