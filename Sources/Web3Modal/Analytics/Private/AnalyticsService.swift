import Foundation

class AnalyticsService: AnalyticsProvider, ObservableObject {
    private let providers: [AnalyticsProvider]

    init(providers: [AnalyticsProvider]) {
        self.providers = providers
    }

    func track(_ event: AnalyticsEvent) {
        providers.forEach {
            $0.track(event)
        }
    }
}
