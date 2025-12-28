//
//  AlarmDTO.swift
//  MeloMeter
//
//  Created by LTS on 2023/10/01.
//

import Foundation

public struct AlarmDTO {
    
    // MARK: - Properties
    public let text: String
    public let date: String
    public let type: String
    
    public init(text: String, date: String, type: String) {
        self.text = text
        self.date = date
        self.type = type
    }
    
    // MARK: - Methods
    public func toModel() -> AlarmModel {
        let alarmType = AlarmType(rawValue: type) ?? AlarmType.defaultValue
                
        return AlarmModel(
            text: text,
            date: Date.stringToDate(dateString: date, type: .yearToDay) ?? Date(),
            type: alarmType)
    }
}
