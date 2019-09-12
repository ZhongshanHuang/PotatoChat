//
//  UITextView+Emoticon.swift
//  Animation3.0
//
//  Created by 黄山哥 on 2017/7/13.
//  Copyright © 2017年 黄山哥. All rights reserved.
//

import UIKit

extension UITextView {
    // 输入表情符号
    func insertEmoticon(em: EmoticonModel) {
        // 空白表情
        if em.isEmpty {
            return
        }
        // 删除按钮
        if em.isRemoved {
            deleteBackward()
            return
        }
        // emoji表情
        if let emoticon = em.emoticon {
            replace(selectedTextRange!, withText: emoticon)
            return
        }
        
        if let chs = em.chs {
            replace(selectedTextRange!, withText: chs)
            return
        }

//        // 图片表情-----
//        let attachment = EmoticonAttachment(emoticonModel: em)
//        // 转换文本
//        let mstr = NSMutableAttributedString(attributedString: attributedText)
//        // 插入图片
//        mstr.replaceCharacters(in: selectedRange, with: attachment.imageText(font: font!))
//        // 记录光标目前的位置
//        let range = selectedRange
//        // 替换文本
//        attributedText = mstr
//        // 恢复光标
//        selectedRange = NSRange(location: range.location + 1, length: 0)
    }

    var emoticonText: String {
        var mStr = ""
        attributedText.enumerateAttributes(in: NSRange(location: 0, length: attributedText.length), options: []) { (dic, range, _) in

            if let attachment = dic[.attachment] as? EmoticonAttachment {
                mStr += attachment.emoticonModel.chs!
            } else {
                let str = (text as NSString).substring(with: range)
                mStr += str
            }
        }
        return mStr
    }

}

