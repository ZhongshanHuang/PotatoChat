//
//  TextMessageCell.swift
//  MessageExample
//
//  Created by 黄中山 on 2017/11/28.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import UIKit

/// A subclass of `MessageContentCell` used to display text messages.
class TextMessageCell: MessageContentCell {
    
    // MARK: - Properties
    
    /// The `MessageCellDelegate` for the cell.
    override weak var delegate: MessageCellDelegate? {
        didSet {
            messageLabel.delegate = delegate
        }
    }
    
    /// The label used to display the message's text.
    var messageLabel = MessageLabel()
    
    // MARK: - Methods
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes {
            messageLabel.textInsets = attributes.messageLabelInsets
            messageLabel.messageLabelFont = attributes.messageLabelFont
            messageLabel.frame = messageContainerView.bounds
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.attributedText = nil
        messageLabel.text = nil
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(messageLabel)
    }
    
    override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        
        let enabledDetectors = displayDelegate.enabledDetectors(for: message, at: indexPath, in: messagesCollectionView)
        
        messageLabel.configure {
            messageLabel.enabledDetectors = enabledDetectors
            for detector in enabledDetectors {
                let attributes = displayDelegate.detectorAttributes(for: detector, and: message, at: indexPath)
                messageLabel.setAttributes(attributes, detector: detector)
            }
            switch message.kind {
            case .text(let text), .emoji(let text):
                let textColor = displayDelegate.textColor(for: message, at: indexPath, in: messagesCollectionView)
                messageLabel.text = text
                messageLabel.textColor = textColor
                if let font = messageLabel.messageLabelFont {
                    messageLabel.font = font
                }
            case .attributedText(let text):
                messageLabel.attributedText = text
            default:
                break
            }
        }
    }
    
    /// Used to handle the cell's contentView's tap gesture.
    /// Return false when the contentView does not need to handle the gesture.
    override func cellContentView(canHandle touchPoint: CGPoint) -> Bool {
        return messageLabel.handleGesture(touchPoint)
    }
    
}
