//
//  UIImage+Extension.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/9/6.
//  Copyright © 2019 黄中山. All rights reserved.
//

import UIKit

enum ImageType: String {
    case play
    case pause
    case disclouser
}

/// This extension provide a way to access image resources with in framework
extension UIImage {
    
    class func messageKitImageWith(type: ImageType) -> UIImage? {
        let imagePath = Bundle.main.path(forResource: type.rawValue, ofType: "png")
        let image = UIImage(contentsOfFile: imagePath ?? "")
        return image
    }
    
}
