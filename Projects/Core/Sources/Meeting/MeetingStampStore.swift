import CoreLocation
import Foundation

public final class MeetingStampStore {
    public static let shared = MeetingStampStore()
    public static let didUpdateNotification = Notification.Name("MeetingStampStoreDidUpdate")

    public struct Stamp: Codable {
        public let dateString: String
        public let latitude: Double?
        public let longitude: Double?
    }

    private let stampsKey = "meetingStamps"
    private let pendingKey = "meetingStampPending"

    private init() {}

    public func stamps(coupleId: String?) -> [Stamp] {
        loadStamps(coupleId: coupleId)
    }

    public func pendingStamp(coupleId: String?) -> Stamp? {
        loadPending(coupleId: coupleId)
    }

    public func setPending(date: Date, location: CLLocation?, coupleId: String? = nil) {
        let stamp = Stamp(
            dateString: dateString(from: date),
            latitude: location?.coordinate.latitude,
            longitude: location?.coordinate.longitude
        )
        savePending(stamp, coupleId: coupleId)
    }

    public func clearPending(coupleId: String? = nil) {
        UserDefaults.standard.removeObject(forKey: key(base: pendingKey, coupleId: coupleId))
    }

    @discardableResult
    public func savePendingStamp(coupleId: String? = nil) -> Bool {
        guard let pending = pendingStamp(coupleId: coupleId) else { return false }
        clearPending(coupleId: coupleId)
        return addStamp(pending, coupleId: coupleId)
    }

    public func hasStamp(on components: DateComponents, coupleId: String? = nil) -> Bool {
        guard let date = Calendar.current.date(from: components) else { return false }
        let dateString = dateString(from: date)
        return loadStamps(coupleId: coupleId).contains(where: { $0.dateString == dateString })
    }

    public func stampedDateComponents(coupleId: String? = nil) -> [DateComponents] {
        loadStamps(coupleId: coupleId)
            .compactMap { date(from: $0.dateString) }
            .map { Calendar.current.dateComponents([.year, .month, .day], from: $0) }
    }

    @discardableResult
    public func addStamp(date: Date, location: CLLocation?, coupleId: String? = nil) -> Bool {
        let stamp = Stamp(
            dateString: dateString(from: date),
            latitude: location?.coordinate.latitude,
            longitude: location?.coordinate.longitude
        )
        return addStamp(stamp, coupleId: coupleId)
    }

    @discardableResult
    private func addStamp(_ stamp: Stamp, coupleId: String? = nil) -> Bool {
        var stamps = loadStamps(coupleId: coupleId)
        guard stamps.contains(where: { $0.dateString == stamp.dateString }) == false else { return false }
        stamps.append(stamp)
        saveStamps(stamps, coupleId: coupleId)
        NotificationCenter.default.post(name: MeetingStampStore.didUpdateNotification, object: nil)
        return true
    }

    private func loadStamps(coupleId: String? = nil) -> [Stamp] {
        let key = key(base: stampsKey, coupleId: coupleId)
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([Stamp].self, from: data)) ?? []
    }

    private func saveStamps(_ stamps: [Stamp], coupleId: String? = nil) {
        guard let data = try? JSONEncoder().encode(stamps) else { return }
        let key = key(base: stampsKey, coupleId: coupleId)
        UserDefaults.standard.set(data, forKey: key)
    }

    private func loadPending(coupleId: String? = nil) -> Stamp? {
        let key = key(base: pendingKey, coupleId: coupleId)
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(Stamp.self, from: data)
    }

    private func savePending(_ stamp: Stamp, coupleId: String? = nil) {
        guard let data = try? JSONEncoder().encode(stamp) else { return }
        let key = key(base: pendingKey, coupleId: coupleId)
        UserDefaults.standard.set(data, forKey: key)
    }

    private func key(base: String, coupleId: String?) -> String {
        guard let coupleId, coupleId.isEmpty == false else { return base }
        return "\(base)-\(coupleId)"
    }

    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func date(from string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }
}
