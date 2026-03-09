import Foundation
#if canImport(Core)
import Core
#endif

public extension DateRecordItem {
    var satisfactionTintColorName: String {
        switch satisfaction {
        case 3:
            return "point1"
        case 2:
            return "primary1"
        default:
            return "gray2"
        }
    }
}

public struct DateRecordItem: Codable {
    public let planUUID: String
    public let title: String
    public let locationName: String
    public let category: String
    public let memo: String
    public let satisfaction: Int
    public let isFavorite: Bool
    public let imageDatas: [Data]
    public let createdAt: String

    public init(planUUID: String,
                title: String,
                locationName: String,
                category: String,
                memo: String,
                satisfaction: Int,
                isFavorite: Bool,
                imageDatas: [Data],
                createdAt: String) {
        self.planUUID = planUUID
        self.title = title
        self.locationName = locationName
        self.category = category
        self.memo = memo
        self.satisfaction = satisfaction
        self.isFavorite = isFavorite
        self.imageDatas = imageDatas
        self.createdAt = createdAt
    }
}

public struct DateRecordMonthInsight {
    public let recordCount: Int
    public let favoriteCount: Int
    public let averageSatisfaction: Double
    public let topCategory: String?
}

public final class DateRecordStore {
    public static let shared = DateRecordStore()

    private let storageKey = "date-record-items"

    private init() {}

    public func save(_ item: DateRecordItem, coupleId: String?) {
        var items = load(coupleId: coupleId)
        items.removeAll { $0.planUUID == item.planUUID }
        items.append(item)
        persist(items, coupleId: coupleId)
    }

    public func item(planUUID: String, coupleId: String?) -> DateRecordItem? {
        load(coupleId: coupleId).first { $0.planUUID == planUUID }
    }

    public func hasItem(planUUID: String, coupleId: String?) -> Bool {
        item(planUUID: planUUID, coupleId: coupleId) != nil
    }

    public func items(coupleId: String?) -> [DateRecordItem] {
        load(coupleId: coupleId)
    }

    public func monthInsight(for date: Date, coupleId: String?) -> DateRecordMonthInsight {
        let monthItems = load(coupleId: coupleId).filter {
            guard let createdDate = Date.stringToDate(dateString: $0.createdAt, type: .yearToSecond) else { return false }
            return Calendar.current.isDate(createdDate, equalTo: date, toGranularity: .month)
        }

        let favoriteCount = monthItems.filter { $0.isFavorite }.count
        let topCategory = Dictionary(grouping: monthItems, by: \ .category)
            .max { $0.value.count < $1.value.count }?
            .key
        let averageSatisfaction: Double
        if monthItems.isEmpty {
            averageSatisfaction = 0
        } else {
            averageSatisfaction = Double(monthItems.map(\.satisfaction).reduce(0, +)) / Double(monthItems.count)
        }

        return DateRecordMonthInsight(
            recordCount: monthItems.count,
            favoriteCount: favoriteCount,
            averageSatisfaction: averageSatisfaction,
            topCategory: topCategory
        )
    }

    private func load(coupleId: String?) -> [DateRecordItem] {
        let key = makeKey(coupleId: coupleId)
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([DateRecordItem].self, from: data)) ?? []
    }

    private func persist(_ items: [DateRecordItem], coupleId: String?) {
        let key = makeKey(coupleId: coupleId)
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func makeKey(coupleId: String?) -> String {
        guard let coupleId, coupleId.isEmpty == false else { return storageKey }
        return "\(storageKey)-\(coupleId)"
    }
}
