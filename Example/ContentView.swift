import Web3Modal
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(HelloWorld.greeting())
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
