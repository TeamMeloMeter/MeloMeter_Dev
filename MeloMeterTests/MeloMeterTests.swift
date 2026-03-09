//
//  MeloMeterTests.swift
//  MeloMeterTests
//
//  Created by 오현택 on 2023/10/23.
//

import XCTest
import Domain
@testable import Presentation

final class MeloMeterTests: XCTestCase {
    private var coupleId: String!

    override func setUpWithError() throws {
        coupleId = "test-couple"
        UserDefaults.standard.removeObject(forKey: "date-record-items-\(coupleId!)")
    }

    override func tearDownWithError() throws {
        UserDefaults.standard.removeObject(forKey: "date-record-items-\(coupleId!)")
        coupleId = nil
    }

    func testDateRecordStore_WhenSaveAndRead_ShouldReturnSavedItem() throws {
        let item = DateRecordItem(
            planUUID: "plan-1",
            title: "한강 데이트",
            locationName: "반포한강공원",
            category: "공원",
            memo: "야경이 예뻤다",
            satisfaction: 3,
            isFavorite: true,
            imageDatas: [Data([0x01, 0x02])],
            createdAt: Date().toString(type: .yearToSecond)
        )

        DateRecordStore.shared.save(item, coupleId: coupleId)

        let saved = DateRecordStore.shared.item(planUUID: "plan-1", coupleId: coupleId)

        XCTAssertNotNil(saved)
        XCTAssertEqual(saved?.title, item.title)
        XCTAssertEqual(saved?.imageDatas.count, 1)
        XCTAssertEqual(saved?.satisfaction, 3)
    }

    func testDateRecordStore_WhenMonthInsightRequested_ShouldAggregateRecords() throws {
        let currentMonthDate = Date()
        let formatterDate = currentMonthDate.toString(type: .yearToSecond)
        let first = DateRecordItem(
            planUUID: "plan-1",
            title: "전시회",
            locationName: "성수",
            category: "전시회",
            memo: "좋았다",
            satisfaction: 3,
            isFavorite: true,
            imageDatas: [],
            createdAt: formatterDate
        )
        let second = DateRecordItem(
            planUUID: "plan-2",
            title: "브런치",
            locationName: "연남",
            category: "맛집",
            memo: "무난했다",
            satisfaction: 2,
            isFavorite: false,
            imageDatas: [],
            createdAt: formatterDate
        )

        DateRecordStore.shared.save(first, coupleId: coupleId)
        DateRecordStore.shared.save(second, coupleId: coupleId)

        let insight = DateRecordStore.shared.monthInsight(for: currentMonthDate, coupleId: coupleId)

        XCTAssertEqual(insight.recordCount, 2)
        XCTAssertEqual(insight.favoriteCount, 1)
        XCTAssertEqual(insight.averageSatisfaction, 2.5, accuracy: 0.01)
    }

    func testDatePlanMonthSummary_WhenPlansExist_ShouldCountByMonth() throws {
        let now = Date()
        let today = now.toString(type: .yearToSecond)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: now)?.toString(type: .yearToSecond) ?? today

        let plans = [
            DatePlanModel(
                uuid: "1",
                name: "오늘 약속",
                memo: "",
                mapX: 0,
                mapY: 0,
                roadAddress: "",
                address: "",
                scheduledAt: today,
                createdAt: today,
                createdBy: "tester",
                notifyEnabled: true,
                radiusMeters: 100,
                dwellSeconds: 60,
                checkIns: [:],
                arrivalRecords: [:],
                isOnTime: nil,
                isCompleted: true
            ),
            DatePlanModel(
                uuid: "2",
                name: "내일 약속",
                memo: "",
                mapX: 0,
                mapY: 0,
                roadAddress: "",
                address: "",
                scheduledAt: nextDay,
                createdAt: today,
                createdBy: "tester",
                notifyEnabled: true,
                radiusMeters: 100,
                dwellSeconds: 60,
                checkIns: [:],
                arrivalRecords: [:],
                isOnTime: nil,
                isCompleted: false
            )
        ]

        let summary = plans.monthSummary(for: now, now: now)

        XCTAssertEqual(summary.totalCount, 2)
        XCTAssertEqual(summary.todayCount, 1)
        XCTAssertEqual(summary.completedCount, 1)
    }
}
