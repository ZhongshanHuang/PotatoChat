//
//  LabelAlignment.swift
//  MessageExample
//
//  Created by 黄中山 on 2017/11/25.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import UIKit

struct LabelAlignment {
    var textAlignment: NSTextAlignment
    var textInsets: UIEdgeInsets
    
    init(textAlignment: NSTextAlignment, textInsets: UIEdgeInsets) {
        self.textAlignment = textAlignment
        self.textInsets = textInsets
    }
}


// MARK: - Equatable
extension LabelAlignment: Equatable {
    
    static func == (lhs: LabelAlignment, rhs: LabelAlignment) -> Bool {
        return lhs.textAlignment == rhs.textAlignment && lhs.textInsets == rhs.textInsets
    }
}
