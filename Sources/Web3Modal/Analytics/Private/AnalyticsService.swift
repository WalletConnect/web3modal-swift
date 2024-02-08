import Foundation

class AnalyticsService: AnalyticsProvider, ObservableObject {
    private(set) static var shared = AnalyticsService(providers: [
        LoggingAnalyticsProvider(),
        ClickstreamAnalyticsProvider()
    ])

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

import SwiftUI

struct AnalyticsServiceKey: EnvironmentKey {
    static var defaultValue: AnalyticsService = .shared
}

extension EnvironmentValues {
    var analyticsService: AnalyticsService {
        get { self[AnalyticsServiceKey.self] }
        set { self[AnalyticsServiceKey.self] = newValue }
    }
}
