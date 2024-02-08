class DefaultAnalyticsEventMapper: AnalyticsEventMapper {
    func eventName(for event: AnalyticsEvent) -> String {
        event.rawValue
    }

    func parameters(for event: AnalyticsEvent) -> [String: String] {
        [:]
    }
}
