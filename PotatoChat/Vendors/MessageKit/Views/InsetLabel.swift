//
//  InsetLabel.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/1/6.
//  Copyright © 2019 黄中山. All rights reserved.
//

import UIKit

class InsetLabel: UILabel {
    
    var textInsets: UIEdgeInsets = .zero {
        didSet { setNeedsDisplay() }
    }
    
    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: textInsets)
        super.drawText(in: insetRect)
    }
}
