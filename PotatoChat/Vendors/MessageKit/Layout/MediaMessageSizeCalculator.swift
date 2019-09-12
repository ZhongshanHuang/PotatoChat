//
//  MediaMessageSizeCalculator.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/1/9.
//  Copyright © 2019 黄中山. All rights reserved.
//

import UIKit

class MediaMessageSizeCalculator: MessageSizeCalculator {
    
    override func messageContainerSize(for message: MessageType) -> CGSize {
        switch message.kind {
        case .photo(let item), .video(let item):
            var maxWidth = messageContainerMaxWidth(for: message)
            maxWidth = maxWidth / 2
            let size = item.size
            var width = size.width
            var height = size.height
            if size.width >= size.height { // 宽图
                if size.width > maxWidth {
                    width = maxWidth
                    height = width * size.height / size.width
                }
            } else { // 窄图
                if size.height > maxWidth {
                    height = maxWidth
                    width = height * size.width / size.height
                }
            }
            return CGSize(width: width, height: height)
        default:
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }
    }

}
