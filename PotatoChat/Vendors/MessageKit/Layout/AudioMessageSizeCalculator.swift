//
//  AudioMessageSizeCalculator.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/9/6.
//  Copyright © 2019 黄中山. All rights reserved.
//

import Foundation

class AudioMessageSizeCalculator: MessageSizeCalculator {
    
    override func messageContainerSize(for message: MessageType) -> CGSize {
        switch message.kind {
        case .audio(let item):
            let maxWidth = messageContainerMaxWidth(for: message)
            if maxWidth < item.size.width {
                // Maintain the ratio if width is too great
                let height = maxWidth * item.size.height / item.size.width
                return CGSize(width: maxWidth, height: height)
            }
            return item.size
        default:
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }
    }
}
