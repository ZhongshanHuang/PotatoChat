//
//  EmiticonAttachment.swift
//  Animation3.0
//
//  Created by 黄山哥 on 2017/7/11.
//  Copyright © 2017年 黄山哥. All rights reserved.
//

import UIKit

class EmoticonAttachment: NSTextAttachment {
    let emoticonModel: EmoticonModel

    init(emoticonModel: EmoticonModel) {
        self.emoticonModel = emoticonModel
        super.init(data: nil, ofType: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func imageText(font: UIFont) -> NSMutableAttributedString {
        // 字体的高度
        let lineHeight = font.lineHeight
        // 图片附件
        bounds = CGRect(x: 0, y: -6, width: lineHeight, height: lineHeight)
        image = UIImage(contentsOfFile: emoticonModel.imagePath)
        let imageText = NSMutableAttributedString(attributedString: NSAttributedString(attachment: self))
        // 添加字体大小
        imageText.addAttribute(.font, value: font, range: NSRange(location: 0, length: 1))

        return imageText
    }
}
