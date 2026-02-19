//
//  DomainDTOMapper.swift
//  MeloMeter
//
//  Created by Codex on 2025/12/28.
//

import Foundation
import Domain

extension ChatMessage {
    func toDTO() -> ChatDTO {
        guard case let .text(text) = content else {
            return ChatDTO(
                chatType: ChatType.text.stringType,
                contents: "",
                userId: sender.id,
                messageId: messageId,
                date: sentDate
            )
        }
        return ChatDTO(
            chatType: ChatType.text.stringType,
            contents: text,
            userId: sender.id,
            messageId: messageId,
            date: sentDate
        )
    }

    func toDTO(url: String) -> ChatDTO {
        return ChatDTO(
            chatType: ChatType.image.stringType,
            contents: url,
            userId: sender.id,
            messageId: messageId,
            date: sentDate
        )
    }
}

extension CoupleModel {
    func toDTO() -> CoupleDTO {
        return CoupleDTO(
            firstDay: firstDay.toString(type: .yearToDay),
            anniName: anniversaries.map { $0.dateName },
            anniDate: anniversaries.map { $0.date.toString(type: .yearToDay) },
            disconnectedDate: disconnectedDate?.toString(type: .timeStamp)
        )
    }
}

extension UserModel {
    func toProfileInsertDTO(uid: String, phoneNumber: String) -> UserDTO {
        return UserDTO(
            fcmToken: fcmToken,
            uid: uid,
            otherUid: otherUid,
            coupleID: coupleID,
            phoneNumber: phoneNumber,
            profileImagePath: profileImage,
            name: name ?? "",
            birth: birth?.toString(type: .yearToDay) ?? "",
            stateMessage: stateMessage,
            gender: gender?.stringType,
            createdAt: createdAt?.toString(type: .timeStamp)
        )
    }
}

extension AnswerModel {
    func toDTO() -> AnswerDTO {
        return AnswerDTO(
            userId: userId.toUid,
            answerText: answerText,
            userName: userName
        )
    }
}

extension AnswerInfoModel {
    func toDTO() -> AnswerInfoDTO {
        return AnswerInfoDTO(
            answerInfo: answerInfo.map { $0.toDTO() },
            questionText: questionText,
            date: date.toString(type: .yearToHour)
        )
    }
}
