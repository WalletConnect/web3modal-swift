import Foundation

class RecentWalletsStorage {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var recentWallets: [Wallet] {
        get {
            loadRecentWallets()
        }
        set {
            saveRecentWallets(newValue)
        }
    }
    
    func loadRecentWallets() -> [Wallet] {
        guard
            let data = defaults.data(forKey: "recentWallets"),
            let wallets = try? JSONDecoder().decode([Wallet].self, from: data)
        else {
            return []
        }
        
        return wallets.filter { wallet in
            guard let lastTimeUsed = wallet.lastTimeUsed else {
                assertionFailure("Shouldn't happen we stored wallet without `lastTimeUsed`")
                return false
            }
            
            // Consider Recent only for 3 days
            return abs(lastTimeUsed.timeIntervalSinceNow) < (24 * 60 * 60 * 3)
        }
    }
    
    func saveRecentWallets(_ wallets: [Wallet])  {
        
        let subset = Array(wallets.filter {
            $0.lastTimeUsed != nil
        }.prefix(5))
        
        var uniqueValues: [Wallet] = []
        subset.forEach { item in
            guard !uniqueValues.contains(where: { wallet in
                item.id == wallet.id
            }) else { return }
            uniqueValues.append(item)
        }
        
        guard
            let walletsData = try? JSONEncoder().encode(uniqueValues)
        else {
            return
        }
        
        defaults.set(walletsData, forKey: "recentWallets")
    }
}
