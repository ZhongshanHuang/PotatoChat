//
//  MessageKitDateFormatter.swift
//  MessageExample
//
//  Created by 黄中山 on 2017/11/25.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import Foundation

class MessageKitDateFormatter {
    // MARK: - Properties
    
    static let shared = MessageKitDateFormatter()
    
    let formatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh-Hans") // 简体中文
        return formatter
    }()
    
    // MARK: - Initializer
    
    private init() {}
    
    // MARK: - Methods
    
    func string(from date: Date) -> String {
        configureDateFormatter(for: date)
        return formatter.string(from: date)
    }
    
    func attributedString(from date: Date, with attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let dateString = string(from: date)
        return NSAttributedString(string: dateString, attributes: attributes)
    }
    
    private func configureDateFormatter(for date: Date) {
        switch true {
        case Calendar.current.isDateInToday(date) || Calendar.current.isDateInYesterday(date):
            formatter.doesRelativeDateFormatting = true
            formatter.dateStyle = .short
            formatter.timeStyle = .short
        case Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear):
            formatter.dateFormat = "EEEE h:mm a"
        case Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year):
            formatter.dateFormat = "MMM d, h:mm a"
        default:
            formatter.dateFormat = "yyyy MMM d, h:mm a"
        }
    }
}
