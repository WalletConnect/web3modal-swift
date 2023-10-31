import SwiftUI
import Web3ModalUI

struct ChainSelectView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var store: Store
    
    @ObservedObject var viewModel: Web3ModalViewModel

    var body: some View {
        VStack(spacing: 0) {
            modalHeader()
            Divider()
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
        }
    }
    
    @ViewBuilder
    private func grid() -> some View {
        let collumns = Array(repeating: GridItem(.flexible()), count: 4)

        ScrollView {
            LazyVGrid(columns: collumns) {
                ForEach(ChainsPresets.ethChains, id: \.self) { chain in
                    gridElement(for: chain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical)
        }
    }

    private func gridElement(for chain: Chain) -> some View {
        
        let isSelected = chain.id == store.selectedChain?.id
        let currentChains = viewModel.getChains()
        let isChainApproved = true // store.session != nil ? currentChains.contains(chain) : true
        
        return Button(action: {
            Task {
                await self.viewModel.switchChain(chain)
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
        .disabled(isSelected || !isChainApproved)
    }
    
    private func modalHeader() -> some View {
        HStack(spacing: 0) {
            switch router.currentRoute as? Router.NetworkSwitchSubpage {
            case .none:
                EmptyView()
            case .selectChain:
                if router.previousRoute as? Router.AccountSubpage == .profile {
                    backButton()
                } else {
                    helpButton()
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
    
    private func helpButton() -> some View {
        Button(action: {
            router.setRoute(Router.NetworkSwitchSubpage.whatIsANetwork)
        }, label: {
            Image.QuestionMarkCircle
        })
    }
    
    private func backButton() -> some View {
        Button {
            router.goBack()
        } label: {
            Image.LargeBackward
        }
    }
    
    private func closeButton() -> some View {
        Button {
            withAnimation {
                store.isModalShown = false
            }
        } label: {
            Image.LargeClose
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
        }
    }
}
