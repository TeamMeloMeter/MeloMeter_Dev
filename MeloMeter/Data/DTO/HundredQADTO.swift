//
//  HundredQADTO.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import Foundation

struct HundredQADTO: Codable {
    
    // MARK: - Properties
    let answerList: [[String: String]]
    
    // MARK: - Methods
//    func toModel() -> HundredQAModel {
//        return HundredQAModel(
//            userID: answerList[0][""] == UserDefaults.standard.string(forKey: "uid") ? .mine : .other,
//            answerText: answerText
//        )
//    }
}
