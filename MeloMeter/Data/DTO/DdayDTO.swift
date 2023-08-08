//
//  CoupleDTO.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/07.
//

import Foundation

struct DdayDTO: Codable {
    
    // MARK: - Properties
    let firstDay: String
    let anniversaries: [String]
    
    // MARK: - Methods
    func toModel() -> DdayModel {
        return DdayModel(
            firstDay: Date.stringToDate(dateString: firstDay, type: .yearToDay) ?? Date(),
            anniversaries: anniversaries.map({ Date.stringToDate(dateString: $0, type: .yearToDay) ?? Date() })
        )
    }
}
