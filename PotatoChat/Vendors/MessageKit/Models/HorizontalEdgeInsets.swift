//
//  HorizontalEdgeInsets.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/1/7.
//  Copyright © 2019 黄中山. All rights reserved.
//

import Foundation


struct HorizontalEdgeInsets {
    
    var left: CGFloat
    var right: CGFloat
    
    init(left: CGFloat, right: CGFloat) {
        self.left = left
        self.right = right
    }
    
    static var zero: HorizontalEdgeInsets {
        return HorizontalEdgeInsets(left: 0, right: 0)
    }
}

extension HorizontalEdgeInsets: Equatable {
    
    static func == (lhs: HorizontalEdgeInsets, rhs: HorizontalEdgeInsets) -> Bool {
        return lhs.left == rhs.left && lhs.right == rhs.right
    }
}

extension HorizontalEdgeInsets {
    
    var horizontal: CGFloat {
        return left + right
    }
}


