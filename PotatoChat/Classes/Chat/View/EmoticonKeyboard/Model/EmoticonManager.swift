//
//  EmoticonViewModel.swift
//  Animation3.0
//
//  Created by 黄山哥 on 2017/6/1.
//  Copyright © 2017年 黄山哥. All rights reserved.
//

import Foundation

struct EmoticonManager {
    
//    static let shared = EmoticonManager()
    // 表情包模型
    var packages = [EmoticonPackage]()
    
    init() {
        // 在bundle下找到emoticons.plist路径
        let bundle = Bundle(for: EmoticonPackage.self)
        guard let filePath = bundle.path(forResource: "Emoticons", ofType: "bundle"), let fileBundle = Bundle(path: filePath) else {
            debugPrint("filePath not found")
            return
        }
        
        guard let emoticonsPath = fileBundle.path(forResource: "emoticons", ofType: "plist") else {
            debugPrint("emoticons.plist not found")
            return
        }
        // 加载emoticons.plist
        let dict = NSDictionary(contentsOfFile: emoticonsPath)!
        
        let array = (dict["packages"] as! NSArray).value(forKey: "id")
        
        for id in array as! [String] {
            let newPath = fileBundle.path(forResource: "content.plist", ofType: nil, inDirectory: id)!
            let dict = NSDictionary(contentsOfFile: newPath) as! [String: Any]
            packages.append(EmoticonPackage(dict: dict))
        }
    }
}
