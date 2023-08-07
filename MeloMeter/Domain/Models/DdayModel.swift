//
//  CoupleModel.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/07.
//

import Foundation

struct DdayModel: Equatable, Hashable {

    // MARK: - Properties
    let firstDay: Date
    let anniversaries: [Date]
    
    // MARK: - Methods
    func toDTO() -> DdayDTO {
        return DdayDTO(
            firstDay: firstDay.toString(type: .yearAndMonthAndDate),
            anniversaries: anniversaries.map{ $0.toString(type: .yearAndMonthAndDate) }
        )
    }
}
