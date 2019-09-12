//
//  ChatMessage.swift
//  WeChat
//
//  Created by 黄中山 on 2018/1/9.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import Foundation
import CoreLocation

private struct CoordinateItem: LocationItem {
    
    var location: CLLocation
    var size: CGSize
    
    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
    
}

private struct ImageMediaItem: MediaItem {
    /// 缩略图
    var thumbnailURL: URL
    /// 原图
    var sourceURL: URL?
    /// 图片大小
    var size: CGSize
    
    init(thumbnailURL: String, sourceURL: String?, size: CGSize, isLocal: Bool = false) {
        if isLocal {
            self.thumbnailURL = URL(fileURLWithPath: thumbnailURL)
            if let url = sourceURL {
                self.sourceURL = URL(fileURLWithPath: url)
            }
        } else {
            self.thumbnailURL = URL(string: thumbnailURL)!
            if let url = sourceURL {
                self.sourceURL = URL(string: url)
            }
        }
        self.size = size
    }
}

struct ChatMessage: MessageType {
    
    var messageId: String
    var sender: SenderType
    var sentDate: Date
    var kind: MessageKind
    
    private init(kind: MessageKind, sender: SenderType, messageId: String, date: Date) {
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }
    
    init(custom: Any?, sender: SenderType, messageId: String, date: Date) {
        self.init(kind: .custom(custom), sender: sender, messageId: messageId, date: date)
    }
    
    init(text: String, sender: SenderType, messageId: String, date: Date) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
    }
    
    init(attributedText: NSAttributedString, sender: SenderType, messageId: String, date: Date) {
        self.init(kind: .attributedText(attributedText), sender: sender, messageId: messageId, date: date)
    }
    
    init(thumbnailURL: String, sourceURL: String? = nil, size: CGSize, isLocal: Bool = false, sender: SenderType, messageId: String, date: Date) {
        let imageItem = ImageMediaItem(thumbnailURL: thumbnailURL, sourceURL: sourceURL, size: size, isLocal: isLocal)
        self.init(kind: .photo(imageItem), sender: sender, messageId: messageId, date: date)
    }
    
    init(location: CLLocation, sender: SenderType, messageId: String, date: Date) {
        let locationItem = CoordinateItem(location: location)
        self.init(kind: .location(locationItem), sender: sender, messageId: messageId, date: date)
    }
    
    init(emoji: String, sender: SenderType, messageId: String, date: Date) {
        self.init(kind: .emoji(emoji), sender: sender, messageId: messageId, date: date)
    }
    
}
