//
//  ChatModel.swift
//  MeloMeter
//
//  Created by Codex on 2025/12/28.
//

import AVFoundation
import CoreLocation
import Foundation
import MessageKit
import UIKit

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

public struct ChatModel: MessageType {

    // MARK: Lifecycle

    private init(kind: MessageKind, user: ChatUserModel, messageId: String, date: Date) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        sentDate = date
    }

    public init(text: String, user: ChatUserModel, messageId: String, date: Date) {
        self.init(kind: .text(text), user: user, messageId: messageId, date: date)
    }

    public init(image: UIImage, user: ChatUserModel, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date)
    }

    public init(imageURL: URL, user: ChatUserModel, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(imageURL: imageURL)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date)
    }

    // MARK: Internal

    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind

    public var user: ChatUserModel

    public var sender: SenderType {
        user
    }
}
