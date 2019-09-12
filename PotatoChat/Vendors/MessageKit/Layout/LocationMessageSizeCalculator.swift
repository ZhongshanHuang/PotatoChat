//
//  LocationMessageSizeCalculator.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/1/9.
//  Copyright © 2019 黄中山. All rights reserved.
//

import UIKit

class LocationMessageSizeCalculator: MessageSizeCalculator {
    
    override func messageContainerSize(for message: MessageType) -> CGSize {
        switch message.kind {
        case .location(let item):
            let maxWidth = messageContainerMaxWidth(for: message)
            if maxWidth < item.size.width {
                let height = maxWidth * item.size.height / item.size.width
                return CGSize(width: maxWidth, height: height)
            }
            return item.size
        default:
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }
    }
}
