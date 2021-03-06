//
//  TextMessageSizeCalculator.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/1/9.
//  Copyright © 2019 黄中山. All rights reserved.
//

import UIKit

class TextMessageSizeCalculator: MessageSizeCalculator {
    
    var incomingMessageLabelInsets = UIEdgeInsets(top: 7, left: 18, bottom: 7, right: 14)
    var outgoingMessageLabelInsets = UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 18)
    
    var messageLabelFont = UIFont.preferredFont(forTextStyle: .body)
    
    func messageLabelInsets(for message: MessageType) -> UIEdgeInsets {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingMessageLabelInsets : incomingMessageLabelInsets
    }
    
    override func messageContainerMaxWidth(for message: MessageType) -> CGFloat {
        let maxWidth = super.messageContainerMaxWidth(for: message)
        let textInsets = messageLabelInsets(for: message)
        return maxWidth - textInsets.horizontal
    }
    
    override func messageContainerSize(for message: MessageType) -> CGSize {
        let maxWidth = messageContainerMaxWidth(for: message)
        
        var messageContainerSize: CGSize
        let attributedText: NSAttributedString
        
        switch message.kind {
        case .attributedText(let text):
            attributedText = text
        case .text(let text), .emoji(let text):
            attributedText = NSAttributedString(string: text, attributes: [.font: messageLabelFont])
        default:
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }
        
        messageContainerSize = labelSize(for: attributedText, considering: maxWidth)
        
        let messageInsets = messageLabelInsets(for: message)
        messageContainerSize.width += messageInsets.horizontal
        messageContainerSize.height += messageInsets.vertical
        
        return messageContainerSize
    }
    
    override func configure(attributes: UICollectionViewLayoutAttributes) {
        super.configure(attributes: attributes)
        guard let attributes = attributes as? MessagesCollectionViewLayoutAttributes else { return }
        
        let dataSource = messagesLayout.messagesDataSource
        let indexPath = attributes.indexPath
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)
        
        attributes.messageLabelInsets = messageLabelInsets(for: message)
        attributes.messageLabelFont = messageLabelFont
        
        switch message.kind {
        case .attributedText(let text):
            guard !text.string.isEmpty else { return }
            guard let font = text.attribute(.font, at: 0, effectiveRange: nil) as? UIFont else { return }
            attributes.messageLabelFont = font
        default:
            break
        }
    }
}

