//
//  ContactMessageSizeCalculator.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/9/6.
//  Copyright © 2019 黄中山. All rights reserved.
//

import Foundation

class ContactMessageSizeCalculator: MessageSizeCalculator {
    
    var incomingMessageNameLabelInsets = UIEdgeInsets(top: 7, left: 46, bottom: 7, right: 30)
    var outgoingMessageNameLabelInsets = UIEdgeInsets(top: 7, left: 41, bottom: 7, right: 35)
    var contactLabelFont = UIFont.preferredFont(forTextStyle: .body)
    
    func contactLabelInsets(for message: MessageType) -> UIEdgeInsets {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingMessageNameLabelInsets : incomingMessageNameLabelInsets
    }
    
    override func messageContainerMaxWidth(for message: MessageType) -> CGFloat {
        let maxWidth = super.messageContainerMaxWidth(for: message)
        let textInsets = contactLabelInsets(for: message)
        return maxWidth - textInsets.horizontal
    }
    
    override func messageContainerSize(for message: MessageType) -> CGSize {
        let maxWidth = messageContainerMaxWidth(for: message)
        
        var messageContainerSize: CGSize
        let attributedText: NSAttributedString
        
        switch message.kind {
        case .contact(let item):
            attributedText = NSAttributedString(string: item.displayName, attributes: [.font: contactLabelFont])
        default:
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }
        
        messageContainerSize = labelSize(for: attributedText, considering: maxWidth)
        
        let messageInsets = contactLabelInsets(for: message)
        messageContainerSize.width += messageInsets.horizontal
        messageContainerSize.height += messageInsets.vertical
        
        return messageContainerSize
    }
    
    override func configure(attributes: UICollectionViewLayoutAttributes) {
        super.configure(attributes: attributes)
        guard let attributes = attributes as? MessagesCollectionViewLayoutAttributes else { return }
        attributes.messageLabelFont = contactLabelFont
    }
    
}
