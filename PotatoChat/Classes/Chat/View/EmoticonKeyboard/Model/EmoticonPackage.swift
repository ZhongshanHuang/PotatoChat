//
//  EmoticonPackage.swift
//  Animation3.0
//
//  Created by 黄山哥 on 2017/6/1.
//  Copyright © 2017年 黄山哥. All rights reserved.
//

import UIKit

class EmoticonPackage {
    // 表情包路径
    var id: String?
    // 表情包名称
    var group_name_cn: String?
    // 表情数组
    lazy var emoticons = [EmoticonModel]()

    init(dict: [String: Any]) {
        self.id = dict["id"] as? String
        self.group_name_cn = dict["group_name_cn"] as? String
        
        if let array = dict["emoticons"] as? [[String: Any]] {

            var index = 0
            let decoder = JSONDecoder()
            for dic in array {
                let emoticon = try! decoder.decode(EmoticonModel.self, from: JSONSerialization.data(withJSONObject: dic, options: []))
                emoticons.append(emoticon)
                index += 1
                if index == 20 {
                    //添加删除按钮
                    emoticons.append(EmoticonModel(isRemoved: true))
                    index = 0
                }
            }
        }
        appendEmptyEmoticon()
    }

    private func appendEmptyEmoticon() {
        let count = emoticons.count % 21
        if emoticons.count > 0 && count == 0 {
            return
        }
        
        for _ in 0..<count {
            emoticons.append(EmoticonModel(isEmpty: true))
        }
        emoticons.append(EmoticonModel(isRemoved: true))
    }
}
