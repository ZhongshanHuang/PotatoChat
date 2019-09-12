//
//  NSConstraintLayoutSet.swift
//  MessageExample
//
//  Created by 黄中山 on 2017/11/26.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import UIKit

class NSLayoutConstraintSet {
    
    var top: NSLayoutConstraint?
    var bottom: NSLayoutConstraint?
    var left: NSLayoutConstraint?
    var right: NSLayoutConstraint?
    var centerX: NSLayoutConstraint?
    var centerY: NSLayoutConstraint?
    var width: NSLayoutConstraint?
    var height: NSLayoutConstraint?
    
    init(top: NSLayoutConstraint? = nil, bottom: NSLayoutConstraint? = nil,
        left: NSLayoutConstraint? = nil, right: NSLayoutConstraint? = nil,
        centerX: NSLayoutConstraint? = nil, centerY: NSLayoutConstraint? = nil,
        width: NSLayoutConstraint? = nil, height: NSLayoutConstraint? = nil) {
        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
        self.centerX = centerX
        self.centerY = centerY
        self.width = width
        self.height = height
    }
    
    private var availableConstraints: [NSLayoutConstraint] {
        return [top, bottom, left, right, centerX, centerY, width, height].compactMap {$0}
    }
    
    @discardableResult
    func activate() -> Self {
        NSLayoutConstraint.activate(availableConstraints)
        return self
    }
    
    @discardableResult
    func deactivate() -> Self {
        NSLayoutConstraint.deactivate(availableConstraints)
        return self
    }
}
