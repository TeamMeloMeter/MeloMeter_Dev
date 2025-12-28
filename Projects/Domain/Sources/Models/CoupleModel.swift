//
//  CoupleModel.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/07.
//

import Foundation

public struct DdayCellData {
    public var dateName: String
    public var date: Date
    public var countDdays: String

    public init(dateName: String, date: Date, countDdays: String) {
        self.dateName = dateName
        self.date = date
        self.countDdays = countDdays
    }
}

public struct CoupleModel {

    // MARK: - Properties
    public let firstDay: Date
    public let anniversaries: [DdayCellData]
    public let disconnectedDate: Date?
    
    public init(firstDay: Date, anniversaries: [DdayCellData], disconnectedDate: Date?) {
        self.firstDay = firstDay
        self.anniversaries = anniversaries
        self.disconnectedDate = disconnectedDate
    }
    
    public init(firstDay: Date, anniversaries: [DdayCellData]) {
        self.init(firstDay: firstDay, anniversaries: anniversaries, disconnectedDate: nil)
    }

    
    // MARK: - Methods
    public func toDTO() -> CoupleDTO {
        return CoupleDTO(
            firstDay: firstDay.toString(type: .yearToDay),
            anniName: anniversaries.map{ $0.dateName },
            anniDate: anniversaries.map{ $0.date.toString(type: .yearToDay) },
            disconnectedDate: (disconnectedDate?.toString(type: .timeStamp)) ?? nil
        )
    }
}
