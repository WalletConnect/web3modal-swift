import SwiftUI
import Web3ModalUI

struct ChainSelectView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var store: Store
    
    @ObservedObject var viewModel: Web3ModalViewModel

    var body: some View {
        VStack(spacing: 0) {
            modalHeader()
            routes()
        }
        .background(Color.Background125)
        .cornerRadius(30, corners: [.topLeft, .topRight])
    }

    @ViewBuilder
    private func routes() -> some View {
        switch router.currentRoute as? Router.NetworkSwitchSubpage {
        case .none:
            EmptyView()
        case .selectChain:
            grid()
        case .whatIsANetwork:
            WhatIsNetworkView()
        case let .networkDetail(chain):
            NetworkDetailView(viewModel: .init(chain: chain, router: router))
        }
    }
    
    @ViewBuilder
    private func grid() -> some View {
        let collumns = Array(repeating: GridItem(.flexible()), count: 4)

        VStack {
            VStack {
                LazyVGrid(columns: collumns) {
                    ForEach(ChainPresets.ethChains, id: \.self) { chain in
                        gridElement(for: chain)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical)
            }
            
         
            Divider()
            
            VStack(spacing: 0) {
                
                Text("Your connected wallet may not support some of the networks available for this dApp")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.small500)
                    .foregroundColor(.Foreground300)
                    .multilineTextAlignment(.center)
                
                Button {
                    router.setRoute(Router.NetworkSwitchSubpage.whatIsANetwork)
                } label: {
                    HStack {
                        Image.Bold.questionMarkCircle
                            .resizable()
                            .frame(width: 12, height: 12)
                        
                        Text("What is a network")
                    }
                    .foregroundColor(.Blue100)
                    .font(.small500)
                }
                .padding(.vertical, Spacing.xs)
                .background(Color.clear)
                .contentShape(Rectangle())
            }
            .padding(.horizontal)
            .padding(.top, Spacing.xs)
            .padding(.bottom, Spacing.xl)
        }
    }

    private func gridElement(for chain: Chain) -> some View {
        
        let isSelected = chain.id == store.selectedChain?.id
        let currentChains = viewModel.getChains()
        let currentMethods = viewModel.getMethods()
        let needToSendSwitchRequest = currentMethods.contains("wallet_switchEthereumChain")
        let isChainApproved = store.session != nil ? currentChains.contains(chain) : true
        
        return Button(action: {
            if store.session == nil  {
                store.selectedChain = chain
                router.setRoute(Router.ConnectingSubpage.connectWallet)
            } else if isChainApproved && !needToSendSwitchRequest {
                store.selectedChain = chain
                router.setRoute(Router.AccountSubpage.profile)
            } else {
                router.setRoute(Router.NetworkSwitchSubpage.networkDetail(chain))
            }
        }, label: {
            Text(chain.chainName)
        })
        .buttonStyle(W3MCardSelectStyle(
            variant: .network,
            imageContent: {
                Image(
                    uiImage: store.chainImages[chain.imageId] ?? UIImage()
                )
                .resizable()
            },
            isSelected: isSelected
        ))
        .disabled({
            if isSelected {
                return true
            }
            
            if store.session == nil {
                return false
            }
            
            if needToSendSwitchRequest {
                return false
            }
            
            if !currentChains.contains(chain) {
                return true
            }
            
            return false
        }())
    }
    
    private func modalHeader() -> some View {
        HStack(spacing: 0) {
            switch router.currentRoute as? Router.NetworkSwitchSubpage {
            case .none:
                EmptyView()
            case .selectChain:
                if router.previousRoute as? Router.AccountSubpage == .profile {
                    backButton()
                }
            default:
                backButton()
            }
            
            Spacer()
            
            (router.currentRoute as? Router.NetworkSwitchSubpage)?.title.map { title in
                Text(title)
                    .font(.paragraph700)
            }
            
            Spacer()
            
            closeButton()
        }
        .padding()
        .frame(height: 64)
        .frame(maxWidth: .infinity)
        .foregroundColor(.Foreground100)
        .overlay(
            RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
                .stroke(Color.GrayGlass005, lineWidth: 1)
        )
        .cornerRadius(30, corners: [.topLeft, .topRight])
    }
    
    private func backButton() -> some View {
        Button {
            router.goBack()
        } label: {
            Image.Medium.chevronLeft
        }
    }
    
    private func closeButton() -> some View {
        Button {
            withAnimation {
                store.isModalShown = false
            }
        } label: {
            Image.Medium.xMark
        }
    }
}

extension Router.NetworkSwitchSubpage {
    var title: String? {
        switch self {
        case .selectChain:
            return "Select network"
        case .whatIsANetwork:
            return "What is a network?"
        case let .networkDetail(chain):
            return chain.chainName
        }
    }
}
