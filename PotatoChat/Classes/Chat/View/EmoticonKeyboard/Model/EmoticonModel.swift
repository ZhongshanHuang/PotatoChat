//
//  Emoticon.swift
//  Animation3.0
//
//  Created by 黄山哥 on 2017/6/1.
//  Copyright © 2017年 黄山哥. All rights reserved.
//

import UIKit

struct EmoticonModel: Decodable {

    enum CodingKeys: String, CodingKey {
        case chs
        case png
        case code
    }

    // type
    var type: Int = 0
    
    // code
    var code: String?

    // 简体中文
    var chs: String?

    // imageName + filePath
    var png: String?

    // 是否是删除按钮标记
    var isRemoved: Bool = false
    
    // 是否空白标记
    var isEmpty: Bool = false
    
    // emoji
    var emoticon: String? {
        return code?.emoticon
    }
    
    // bundlePath
    var imagePath: String {
        guard let png = png else { return "" }
        return Bundle.main.bundlePath + "/Emoticons.bundle/emoticonImage/" + png
    }
    
    init(isEmpty: Bool = false, isRemoved: Bool = false) {
        self.isEmpty = isEmpty
        self.isRemoved = isRemoved
    }
}
