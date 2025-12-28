//
//  HundredQADTO.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import Foundation

public struct AnswerDTO: Codable {
    public let userId: String
    public let answerText: String
    public let userName: String

    public init(userId: String, answerText: String, userName: String) {
        self.userId = userId
        self.answerText = answerText
        self.userName = userName
    }
    
    public func toModel() -> AnswerModel {
        return AnswerModel(
            userId: userId == UserID.mine.toUid ? .mine : .other,
            answerText: answerText,
            userName: userName
        )
    }
}
public struct AnswerInfoDTO {
    
    // MARK: - Properties
    public let answerInfo: [AnswerDTO]
    public let questionText: String
    public let date: String

    public init(answerInfo: [AnswerDTO], questionText: String, date: String) {
        self.answerInfo = answerInfo
        self.questionText = questionText
        self.date = date
    }
    
    public func toModel() -> AnswerInfoModel {
        return AnswerInfoModel(
            answerInfo: answerInfo.map{ answer in
                return answer.toModel()
            },
            questionText: questionText,
            date: Date.fromStringOrNow(date, .yearToHour)
        )
    }
}
