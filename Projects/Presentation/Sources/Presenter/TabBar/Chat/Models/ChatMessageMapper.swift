//
//  ChatMessageMapper.swift
//  MeloMeter
//
//  Created by Codex on 2025/12/28.
//

import Foundation
import UIKit
import Domain
import MessageKit

extension ChatMessage {
    func toChatModel() -> ChatModel {
        let user = ChatUserModel(senderId: sender.id, displayName: sender.displayName)
        switch content {
        case .text(let text):
            return ChatModel(text: text, user: user, messageId: messageId, date: sentDate)
        case .imageURL(let url):
            return ChatModel(imageURL: url, user: user, messageId: messageId, date: sentDate)
        case .imageData(let data):
            if let image = UIImage(data: data) {
                return ChatModel(image: image, user: user, messageId: messageId, date: sentDate)
            }
            return ChatModel(text: "", user: user, messageId: messageId, date: sentDate)
        }
    }
}

extension ChatModel {
    func toChatMessage(imageCompressionQuality: CGFloat = 0.6) -> ChatMessage? {
        let sender = ChatSender(id: user.senderId, displayName: user.displayName)
        switch kind {
        case .text(let text):
            return ChatMessage.text(text, messageId: messageId, sentDate: sentDate, sender: sender)
        case .photo(let mediaItem):
            if let url = mediaItem.url {
                return ChatMessage.imageURL(url, messageId: messageId, sentDate: sentDate, sender: sender)
            }
            if let image = mediaItem.image,
               let data = image.jpegData(compressionQuality: imageCompressionQuality) {
                return ChatMessage.imageData(data, messageId: messageId, sentDate: sentDate, sender: sender)
            }
            return nil
        default:
            return nil
        }
    }

    func toChatType() -> ChatType? {
        switch kind {
        case .text:
            return .text
        case .photo:
            return .image
        default:
            return nil
        }
    }
}
