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
            firstDay: Date.fromStringOrNow(firstDay),
            anniversaries: anniversaries.map({ Date.fromStringOrNow($0) })
        )
    }
}
