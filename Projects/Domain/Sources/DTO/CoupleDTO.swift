//
//  CoupleDTO.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/07.
//

import Foundation

public struct CoupleDTO: Codable {
    
    // MARK: - Properties
    public let firstDay: String
    public let anniName: [String]
    public let anniDate: [String]
    public let disconnectedDate: String?
    
    public init(firstDay: String, anniName: [String], anniDate: [String], disconnectedDate: String?) {
        self.firstDay = firstDay
        self.anniName = anniName
        self.anniDate = anniDate
        self.disconnectedDate = disconnectedDate
    }
    
    // MARK: - Methods
    public func toModel() -> CoupleModel {
        return CoupleModel(
            firstDay: Date.fromStringOrNow(firstDay, .yearToDay),
            anniversaries: zip(anniName, anniDate).map{
                DdayCellData(dateName: $0.0,
                             date: Date.fromStringOrNow($0.1, .yearToDay),
                             countDdays: "")
            },
            disconnectedDate: Date.fromStringOrNow(disconnectedDate ?? "", .timeStamp)
        )
    }
}
