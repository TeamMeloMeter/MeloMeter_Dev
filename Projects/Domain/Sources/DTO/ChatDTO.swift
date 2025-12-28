//
//  ChatDTO.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/13.
//

import Foundation
import UIKit
import MessageKit

public enum ChatType: String, Codable {
    case text
    case image
    
    public var stringType: String {
            switch self {
            case .text:
                return "text"
            case .image:
                return "image"
            }
        }
}

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

    
//     MARK: - Date 형을 firestore에 입력하면 Unix Time Stamp형으로 변환하는 작업
    public func toModel() -> ChatModel {
        
        return ChatModel(
            text: contents ?? "",
            user: ChatUserModel(senderId: userId, displayName: ""),
            messageId: messageId,
            date: date
        )
    }
    
    public func toModel(image: UIImage) -> ChatModel {
        return ChatModel(
            image: image,
            user: ChatUserModel(senderId: userId, displayName: ""),
            messageId: messageId,
            date: date
        )
    }

    
}
