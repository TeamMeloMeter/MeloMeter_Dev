//
//  HundredQAModel.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import Foundation

public enum UserID: String {
    case mine, other
    
    public var toUid: String {
        switch self {
        case .mine:
            return UserDefaults.standard.string(forKey: "uid") ?? ""
        case .other:
            return UserDefaults.standard.string(forKey: "otherUid") ?? ""
        }
    }
    
}

public struct AnswerModel {

    // MARK: - Properties
    public let userId: UserID
    public let answerText: String
    public var userName: String

    public init(userId: UserID, answerText: String, userName: String) {
        self.userId = userId
        self.answerText = answerText
        self.userName = userName
    }
    
    // MARK: - Methods
    public func toDTO() -> AnswerDTO {
        return AnswerDTO(
            userId: userId.toUid,
            answerText: answerText,
            userName: userName
        )
    }
}

public struct AnswerInfoModel {

    // MARK: - Properties
    public let answerInfo: [AnswerModel]
    public let questionText: String
    public let date: Date

    public init(answerInfo: [AnswerModel], questionText: String, date: Date) {
        self.answerInfo = answerInfo
        self.questionText = questionText
        self.date = date
    }
    
    // MARK: - Methods
    public func toDTO() -> AnswerInfoDTO {
        return AnswerInfoDTO(
            answerInfo: answerInfo.map{ answer in
                return answer.toDTO()
            },
            questionText: questionText,
            date: date.toString(type: .yearToHour)
        )
    }
}
