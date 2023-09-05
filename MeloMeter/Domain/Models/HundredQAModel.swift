//
//  HundredQAModel.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import Foundation

enum UserID: String {
    case mine, other
    
    var toUid: String {
        switch self {
        case .mine:
            return UserDefaults.standard.string(forKey: "uid") ?? ""
        case .other:
            return UserDefaults.standard.string(forKey: "otherUid") ?? ""
        }
    }
    
}

struct AnswerModel {

    // MARK: - Properties
    let userId: UserID
    let answerText: String
    var userName: String
    
    // MARK: - Methods
    func toDTO() -> AnswerDTO {
        return AnswerDTO(
            userId: userId.toUid,
            answerText: answerText,
            userName: userName
        )
    }
}

struct AnswerInfoModel {

    // MARK: - Properties
    let answerInfo: [AnswerModel]
    let questionText: String
    let date: Date
    
    // MARK: - Methods
    func toDTO() -> AnswerInfoDTO {
        return AnswerInfoDTO(
            answerInfo: answerInfo.map{ answer in
                return answer.toDTO()
            },
            questionText: questionText,
            date: date.toString(type: .yearToHour)
        )
    }
}
