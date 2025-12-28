//
//  AlarmModel.swift
//  MeloMeter
//
//  Created by LTS on 2023/10/01.
//

import Foundation

public struct AlarmModel {
    // MARK: - Properties
    public let text: String
    public let date: Date
    public let type: AlarmType

    public init(text: String, date: Date, type: AlarmType) {
        self.text = text
        self.date = date
        self.type = type
    }
}
