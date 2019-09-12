//
//  MessageType.swift
//  MessageExample
//
//  Created by 黄中山 on 2017/11/26.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import Foundation

protocol MessageType {
    
    /// The sender of message
    var sender: SenderType { get }
    
    /// The unique identifier for the message
    var messageId: String { get }
    
    /// The date the message was sent
    var sentDate: Date { get }
    
    /// The kind of message and its underlying data
    var kind: MessageKind { get }
}
