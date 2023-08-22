//
//  HundredQAModel.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import Foundation

enum UserID {
    case mine, other
}

struct HundredQAModel {

    // MARK: - Properties
    let userID: UserID
    let answerText: String
    
    
    // MARK: - Methods
//    func toDTO() -> HundredQADTO {
//        return HundredQADTO(
//            userID: (userID == .mine ? UserDefaults.standard.string(forKey: "uid") ?? "" : UserDefaults.standard.string(forKey: "otherUid") ?? ""),
//            answerText: answerText
//        )
//    }
}
