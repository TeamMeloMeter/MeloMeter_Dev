//
//  ChatDTO.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/13.
//

import Foundation
import Domain

public struct ChatDTO: Codable {

// MARK: - Properties
    
    public let chatType: String
    public let contents: String?
    public let userId: String
    public let messageId: String
    public let date: Date

    public init(chatType: String, contents: String?, userId: String, messageId: String, date: Date) {
        self.chatType = chatType
        self.contents = contents
        self.userId = userId
        self.messageId = messageId
        self.date = date
    }

    
    // MARK: - Date 형을 firestore에 입력하면 Unix Time Stamp형으로 변환하는 작업
    public func toMessage() -> ChatMessage {
        let sender = ChatSender(id: userId, displayName: "")
        if chatType == ChatType.image.stringType,
           let contents,
           let url = URL(string: contents) {
            return ChatMessage(
                messageId: messageId,
                sentDate: date,
                sender: sender,
                content: .imageURL(url)
            )
        }

        return ChatMessage(
            messageId: messageId,
            sentDate: date,
            sender: sender,
            content: .text(contents ?? "")
        )
    }

    
}
