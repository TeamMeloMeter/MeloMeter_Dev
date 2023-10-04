//
//  AlarmDTO.swift
//  MeloMeter
//
//  Created by LTS on 2023/10/01.
//

import Foundation

struct AlarmDTO {
    
    // MARK: - Properties
    let text: String
    let date: String
    let type: String
    
    
    // MARK: - Methods
    func toModel() -> AlarmModel {
        let alarmType = AlarmType(rawValue: type) ?? AlarmType.chat
                
        return AlarmModel(
            text: text,
            date: Date.stringToDate(dateString: date, type: .yearToDay) ?? Date(),
            type: alarmType)
    }
}
