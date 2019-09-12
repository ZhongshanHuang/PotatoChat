//
//  String+Emoticon.swift
//  Animation3.0
//
//  Created by 黄山哥 on 2017/6/15.
//  Copyright © 2017年 黄山哥. All rights reserved.
//

import Foundation

// 16进制数据转换成unicode字符串
extension String {
    var emoticon: String {
        let scanner = Scanner(string: self)

        var value: UInt32 = 0
        scanner.scanHexInt32(&value)

        if let x = UnicodeScalar(value) {
//            return "\(Character(x))"
            return String(x)
        }
        return ""
    }
}
