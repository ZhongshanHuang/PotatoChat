//
//  Constant.swift
//  WeChat
//
//  Created by 黄中山 on 2018/1/21.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import Foundation

func debugPrint<T>(_ message: T, file: String = #file, line: Int = #line, method: String = #function) {
    #if DEBUG
    print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}

struct Constant {
    
    /// 在环信创建的appkey
    /// https://console.easemob.com/user/login
    static let app_Key: String = "1119180120178426#wechat"
    
    
    // NotificationName
    static let WeChatDidReceivedMessagesName: Notification.Name = Notification.Name("WeChatReceivedMessagesName")
    static let WeChatConversationListDidUpdateName: Notification.Name = Notification.Name("WeChatConversationListDidUpdateName")
    static let WeChatDidReceiveFriendRequestName: Notification.Name = Notification.Name("WeChatDidReceiveFriendRequestName")
    
    static let userNameKey = "UserNameKey"
    static let passwordKey = "PasswordKey"
}






