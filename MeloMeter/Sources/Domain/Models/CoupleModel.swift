//
//  CoupleModel.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/07.
//

import Foundation

struct DdayCellData {
    var dateName: String
    var date: Date
    var countDdays: String
}

struct CoupleModel {

    // MARK: - Properties
    let firstDay: Date
    let anniversaries: [DdayCellData]
    let disconnectedDate: Date?
    
    init(firstDay: Date, anniversaries: [DdayCellData], disconnectedDate: Date?) {
        self.firstDay = firstDay
        self.anniversaries = anniversaries
        self.disconnectedDate = disconnectedDate
    }
    
    init(firstDay: Date, anniversaries: [DdayCellData]) {
        self.init(firstDay: firstDay, anniversaries: anniversaries, disconnectedDate: nil)
    }

    
    // MARK: - Methods
    func toDTO() -> CoupleDTO {
        return CoupleDTO(
            firstDay: firstDay.toString(type: .yearToDay),
            anniName: anniversaries.map{ $0.dateName },
            anniDate: anniversaries.map{ $0.date.toString(type: .yearToDay) },
            disconnectedDate: (disconnectedDate?.toString(type: .timeStamp)) ?? nil
        )
    }
}
