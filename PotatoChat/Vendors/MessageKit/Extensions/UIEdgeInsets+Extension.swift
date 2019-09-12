//
//  UIEdgeInsets+Extension.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/1/6.
//  Copyright © 2019 黄中山. All rights reserved.
//

import Foundation

extension UIEdgeInsets {
    
    var horizontal: CGFloat {
        return left + right
    }
    
    var vertical: CGFloat {
        return top + bottom
    }
    
}
