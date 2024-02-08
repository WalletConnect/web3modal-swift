class LoggingAnalyticsProvider: AnalyticsProvider {
    private let eventMapper = DefaultAnalyticsEventMapper()

    func track(_ event: AnalyticsEvent) {
        let name = eventMapper.eventName(for: event)
        print("Event reported: \(name)")
    }
}
