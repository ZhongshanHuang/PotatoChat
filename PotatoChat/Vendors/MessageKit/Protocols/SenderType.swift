//
//  SenderType.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/9/6.
//  Copyright © 2019 黄中山. All rights reserved.
//

import Foundation

/// A standard protocol representing a sender.
/// Use this protocol to adhere a object as the sender of a MessageType
protocol SenderType {
    
    /// The unique String identifier for the sender.
    ///
    /// Note: This value must be unique across all senders.
    var senderId: String { get }
    
    /// The display name of a sender.
    var displayName: String { get }
}
