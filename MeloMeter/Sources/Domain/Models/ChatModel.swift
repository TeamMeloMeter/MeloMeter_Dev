//
//  ChatModel.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/07.
//

import AVFoundation
import CoreLocation
import Foundation
import MessageKit
import UIKit
import Firebase

// MARK: - ImageMediaItem

private struct ImageMediaItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        size = CGSize(width: 240, height: 240)
        placeholderImage = UIImage()
    }
    
    init(imageURL: URL) {
        url = imageURL
        size = CGSize(width: 240, height: 240)
        placeholderImage = UIImage(imageLiteralResourceName: "image_message_placeholder")
    }
}
 
// MARK: - ChatModel

internal struct ChatModel: MessageType {
    
    // MARK: Lifecycle
    
    private init(kind: MessageKind, user: ChatUserModel, messageId: String, date: Date) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        sentDate = date
    }
    
    init(text: String, user: ChatUserModel, messageId: String, date: Date) {
        self.init(kind: .text(text), user: user, messageId: messageId, date: date)
    }
    
    init(image: UIImage, user: ChatUserModel, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date)
    }
    
    // MARK: Internal
    
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    var user: ChatUserModel
    
    var sender: SenderType {
        user
    }
    
    func toDTO() -> ChatDTO {
        switch self.kind {
        case .text(let text):
            return ChatDTO(
                chatType: ChatType.text.stringType,
                contents: text,
                userId: self.user.senderId,
                messageId: self.messageId,
                date: Timestamp(date: self.sentDate)
            )
        default:
            break
        }
        return ChatDTO(chatType: ChatType.text.stringType, contents: "", userId: "", messageId: "", date: Timestamp(date: self.sentDate))
    }
    
    func toDTO(url: String) -> ChatDTO {
        switch self.kind {
        case .photo(_):
            return ChatDTO(
                chatType: ChatType.image.stringType,
                contents: url,
                userId: self.user.senderId,
                messageId: self.messageId,
                date: Timestamp(date: self.sentDate)
            )
        default:
            break
        }
        return ChatDTO(chatType: ChatType.image.stringType, contents: "", userId: "", messageId: "", date: Timestamp(date: self.sentDate))
    }
}
