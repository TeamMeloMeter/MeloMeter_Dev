//
//  CoupleDTO.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/07.
//

import Foundation

struct CoupleDTO: Codable {
    
    // MARK: - Properties
    let firstDay: String
    let anniName: [String]
    let anniDate: [String]
    let disconnectedDate: String?
    
    
    // MARK: - Methods
    func toModel() -> CoupleModel {
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
