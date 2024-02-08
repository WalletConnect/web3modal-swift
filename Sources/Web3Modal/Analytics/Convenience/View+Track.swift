import SwiftUI

extension View {
    
    
    func track(@AnalyticsEventGroupBuilder _ groups: () -> [AnalyticsEventGroup]) -> some View {
        let service = Environment(\.analyticsService).wrappedValue
        let groups = groups()
        let modifier = AnalyticsEventTrackingModifier(groups: groups)
        return self.modifier(modifier)
    }

    func track(_ event: AnalyticsEvent) {
        let service = Environment(\.analyticsService).wrappedValue
        service.track(event)
    }

    func track(@AnalyticsEventBuilder _ events: () -> [AnalyticsEvent]) {
        let service = Environment(\.analyticsService).wrappedValue
        let events = events()
        events.forEach { event in
            service.track(event)
        }
    }

    /// Track a group of events in response to the trigger with the provided service.
    func track(_ trigger: AnalyticsEventTrigger, @AnalyticsEventBuilder _ events: () -> [AnalyticsEvent]) -> some View {
        let eventsArray = events()
        let group = AnalyticsEventGroup(trigger, events: eventsArray)
        return track { group }
    }
}

extension AnalyticsService {
    static let shared = AnalyticsService(providers: [
        LoggingAnalyticsProvider(),
        ClickstreamAnalyticsProvider()
    ])
}

struct AnalyticsServiceKey: EnvironmentKey {
    
    static var defaultValue: AnalyticsService = .shared
}

extension EnvironmentValues {
    
    var analyticsService: AnalyticsService {
        get { self[AnalyticsServiceKey.self] }
        set { self[AnalyticsServiceKey.self] = newValue }
    }
}
