import Foundation
import UIKit
#if canImport(Domain)
import Domain
#endif
#if canImport(Core)
import Core
#endif

public enum DatePlanDisplayStatus {
    case upcoming
    case today
    case arrived
    case completed
    case missed

    var title: String {
        switch self {
        case .upcoming:
            return "예정"
        case .today:
            return "오늘"
        case .arrived:
            return "도착"
        case .completed:
            return "완료"
        case .missed:
            return "지남"
        }
    }

    var tintColor: UIColor {
        switch self {
        case .upcoming:
            return .gray2
        case .today:
            return .primary1
        case .arrived:
            return .point1
        case .completed:
            return .gray1
        case .missed:
            return .gray3
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .upcoming:
            return .gray5
        case .today:
            return UIColor.primary1.withAlphaComponent(0.14)
        case .arrived:
            return UIColor.point1.withAlphaComponent(0.22)
        case .completed:
            return UIColor.gray1.withAlphaComponent(0.12)
        case .missed:
            return UIColor.gray4.withAlphaComponent(0.6)
        }
    }
}

public struct DatePlanMonthSummary {
    public let totalCount: Int
    public let todayCount: Int
    public let completedCount: Int
}

public enum DatePlanMapAction: String {
    case focus
    case record
}

public extension Notification.Name {
    static let datePlanSelectedFromCalendar = Notification.Name("DatePlanSelectedFromCalendar")
}

public extension DatePlanModel {
    func scheduledDateValue() -> Date? {
        Date.stringToDate(dateString: scheduledAt, type: .yearToSecond)
    }

    func displayStatus(now: Date = Date(), uid: String? = UserDefaults.standard.string(forKey: "uid")) -> DatePlanDisplayStatus {
        if isCompleted == true {
            return .completed
        }

        if let uid, arrivalRecords[uid] != nil {
            return .arrived
        }

        guard let scheduledDate = scheduledDateValue() else {
            return .upcoming
        }

        if Calendar.current.isDate(scheduledDate, inSameDayAs: now) {
            return .today
        }

        if scheduledDate < now {
            return .missed
        }

        return .upcoming
    }

    func timeText() -> String {
        guard let scheduledDate = scheduledDateValue() else {
            return scheduledAt
        }
        return scheduledDate.toString(format: "a h:mm")
    }

    func monthKey() -> DateComponents? {
        guard let scheduledDate = scheduledDateValue() else { return nil }
        return Calendar.current.dateComponents([.year, .month], from: scheduledDate)
    }

    func dayKey() -> DateComponents? {
        guard let scheduledDate = scheduledDateValue() else { return nil }
        return Calendar.current.dateComponents([.year, .month, .day], from: scheduledDate)
    }
}

public extension Array where Element == DatePlanModel {
    func plans(on date: Date) -> [DatePlanModel] {
        self.filter {
            guard let scheduledDate = $0.scheduledDateValue() else { return false }
            return Calendar.current.isDate(scheduledDate, inSameDayAs: date)
        }
        .sorted {
            ($0.scheduledDateValue() ?? .distantFuture) < ($1.scheduledDateValue() ?? .distantFuture)
        }
    }

    func monthSummary(for monthDate: Date, now: Date = Date()) -> DatePlanMonthSummary {
        let monthPlans = self.filter { plan in
            guard let scheduledDate = plan.scheduledDateValue() else { return false }
            return Calendar.current.isDate(scheduledDate, equalTo: monthDate, toGranularity: .month)
        }
        let todayCount = monthPlans.filter { plan in
            guard let scheduledDate = plan.scheduledDateValue() else { return false }
            return Calendar.current.isDate(scheduledDate, inSameDayAs: now)
        }.count
        let completedCount = monthPlans.filter { $0.isCompleted == true }.count

        return DatePlanMonthSummary(
            totalCount: monthPlans.count,
            todayCount: todayCount,
            completedCount: completedCount
        )
    }
}
