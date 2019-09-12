//
//  ContactItem.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/9/6.
//  Copyright © 2019 黄中山. All rights reserved.
//

import Foundation

/// A protocol used to represent the data for a contact message.
public protocol ContactItem {
    
    /// contact displayed name
    var displayName: String { get }
    
    /// initials from contact first and last name
    var initials: String { get }
    
    /// contact phone numbers
    var phoneNumbers: [String] { get }
    
    /// contact emails
    var emails: [String] { get }
}
