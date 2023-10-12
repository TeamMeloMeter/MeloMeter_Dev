//
//  ChatCustomCells.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/09/02.
//

import UIKit
import MessageKit

// MARK: CustomMessageCell Class
class CustomMessageCell: TextMessageCell {
    
    open override weak var delegate: MessageCellDelegate? {
        didSet {
            messageLabel.delegate = delegate
        }
    }

    override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)

    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.attributedText = nil
        messageLabel.text = nil
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes else { return }
        messageLabel.lineBreakMode = .byCharWrapping
        messageBottomLabel.textInsets = attributes.messageBottomLabelAlignment.textInsets
        if attributes.messageBottomLabelAlignment.textAlignment == .right {
            messageBottomLabel.frame.origin.x = contentView.frame.minX - messageContainerView.frame.width - 10
            messageBottomLabel.frame.origin.y = contentView.frame.maxY - 12
        }else {
            messageBottomLabel.frame.origin.x = messageContainerView.frame.maxX
            messageBottomLabel.frame.origin.y = contentView.frame.maxY - 12
        }
        messageBottomLabel.frame.size.height = 10
        
    }

}

// MARK: CustomPhotoCell Class
class CustomPhotoCell: MediaMessageCell {

    override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)

    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
      
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes else { return }
        messageBottomLabel.textInsets = attributes.messageBottomLabelAlignment.textInsets
        if attributes.messageBottomLabelAlignment.textAlignment == .right {
            messageBottomLabel.frame.origin.x = contentView.frame.minX - messageContainerView.frame.width - 10
            messageBottomLabel.frame.origin.y = contentView.frame.maxY - 12
        }else {
            messageBottomLabel.frame.origin.x = messageContainerView.frame.maxX
            messageBottomLabel.frame.origin.y = contentView.frame.maxY - 12
        }
        messageBottomLabel.frame.size.height = 10
        
    }

}
