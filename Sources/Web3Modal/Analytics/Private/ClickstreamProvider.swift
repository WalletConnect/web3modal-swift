class ClickstreamAnalyticsProvider: AnalyticsProvider {
    private let eventMapper = DefaultAnalyticsEventMapper()

    func track(_ event: AnalyticsEvent) {
        let name = eventMapper.eventName(for: event)
        
        // TODO: POST events
        // TODO: Exponential backoff for retry
        // TODO: Batching?
    }
}
