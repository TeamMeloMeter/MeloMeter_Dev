//
//  AlarmDTO.swift
//  MeloMeter
//
//  Created by LTS on 2023/10/01.
//

import Foundation

struct AlarmDTO {
    
    // MARK: - Properties
    let body: String
    let date: String
    let title: String
    let type: String
    
    
    // MARK: - Methods
    func toModel() -> AlarmModel {
        let alarmType = AlarmType(rawValue: type) ?? AlarmType.chat
        
        return AlarmModel(
            body: body,
            date: Date.fromStringOrNow(date, .yearToDay),
            title: title,
            type: alarmType)
    }
}
