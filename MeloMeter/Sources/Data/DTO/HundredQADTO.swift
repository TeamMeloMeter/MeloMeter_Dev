//
//  HundredQADTO.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import Foundation

struct AnswerDTO: Codable {
    let userId: String
    let answerText: String
    let userName: String
    
    func toModel() -> AnswerModel {
        return AnswerModel(
            userId: userId == UserID.mine.toUid ? .mine : .other,
            answerText: answerText,
            userName: userName
        )
    }
}
struct AnswerInfoDTO {
    
    // MARK: - Properties
    let answerInfo: [AnswerDTO]
    let questionText: String
    let date: String
    
    func toModel() -> AnswerInfoModel {
        return AnswerInfoModel(
            answerInfo: answerInfo.map{ answer in
                return answer.toModel()
            },
            questionText: questionText,
            date: Date.fromStringOrNow(date, .yearToHour)
        )
    }
}
