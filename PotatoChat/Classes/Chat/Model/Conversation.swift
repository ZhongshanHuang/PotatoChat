//
//  Conversation.swift
//  WeChat
//
//  Created by 黄中山 on 2018/1/7.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import Foundation

struct Conversation: Equatable {
    
    var userid: String
    var unreadCounts: Int = 0
    // 最新一条消息的时间
    var messageDate: Double
    // 最新一条消息的类型(暂时还未用到，保留属性)
    var messageType: Int = -1
    var messageContent: String
        
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        return lhs.userid == rhs.userid
    }
}

extension Conversation {

    func timeToString() -> String {
        let calendar = Calendar.current
        let date = Date(timeIntervalSince1970: messageDate)
        let dateComponents = (calendar as NSCalendar).components([.weekday], from: date)
        
        // 是当天
        if calendar.isDateInToday(date) {
            MessageKitDateFormatter.shared.formatter.dateFormat = "HH:mm"
            return MessageKitDateFormatter.shared.formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "昨天"
        } else if calendar.isDateInWeekend(date) { // 在最近7天内
            switch dateComponents.weekday! - 1 {
            case 0:
                return "周日"
            case 1:
                return "周一"
            case 2:
                return "周二"
            case 3:
                return "周三"
            case 4:
                return "周四"
            case 5:
                return "周五"
            case 6:
                return "周六"
            default:
                return "错误🙈"
            }
        } else { // 不在同一周
            MessageKitDateFormatter.shared.formatter.dateFormat = "yyyy/MM/dd"
            return MessageKitDateFormatter.shared.formatter.string(from: date)
        }
    }

}


