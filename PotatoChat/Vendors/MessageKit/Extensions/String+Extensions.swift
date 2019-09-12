//
//  String+Extensions.swift
//  MessageExample
//
//  Created by 黄中山 on 2017/11/26.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import UIKit

extension String {

    func height(considering width: CGFloat, and font: UIFont) -> CGFloat {
        let constraintBox = CGSize(width: width, height: .greatestFiniteMagnitude)
        let rect = self.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: font], context: nil)
        return rect.height
    }

    func width(considering height: CGFloat, and font: UIFont) -> CGFloat {
        let constraintBox = CGSize(width: .greatestFiniteMagnitude, height: height)
        let rect = self.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: font], context: nil)
        return rect.width
    }

}
