//
//  ChatMessage.swift
//  MeloMeter
//
//  Created by Codex on 2025/12/28.
//

import Foundation

public struct ChatSender: Equatable {
    public let id: String
    public let displayName: String

    public init(id: String, displayName: String) {
        self.id = id
        self.displayName = displayName
    }
}

public enum ChatMessageContent: Equatable {
    case text(String)
    case imageURL(URL)
    case imageData(Data)
}

public struct ChatMessage: Equatable {
    public let messageId: String
    public let sentDate: Date
    public let sender: ChatSender
    public let content: ChatMessageContent

    public init(messageId: String, sentDate: Date, sender: ChatSender, content: ChatMessageContent) {
        self.messageId = messageId
        self.sentDate = sentDate
        self.sender = sender
        self.content = content
    }

    public static func text(
        _ text: String,
        messageId: String,
        sentDate: Date,
        sender: ChatSender
    ) -> ChatMessage {
        return ChatMessage(
            messageId: messageId,
            sentDate: sentDate,
            sender: sender,
            content: .text(text)
        )
    }

    public static func imageURL(
        _ url: URL,
        messageId: String,
        sentDate: Date,
        sender: ChatSender
    ) -> ChatMessage {
        return ChatMessage(
            messageId: messageId,
            sentDate: sentDate,
            sender: sender,
            content: .imageURL(url)
        )
    }

    public static func imageData(
        _ data: Data,
        messageId: String,
        sentDate: Date,
        sender: ChatSender
    ) -> ChatMessage {
        return ChatMessage(
            messageId: messageId,
            sentDate: sentDate,
            sender: sender,
            content: .imageData(data)
        )
    }
}
