//
//  AccessoryPosition.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/9/6.
//  Copyright © 2019 黄中山. All rights reserved.
//

import Foundation

/// Used to determine the `Horizontal` and `Vertical` position of
// an `AccessoryView` in a `MessageCollectionViewCell`.
enum AccessoryPosition {
    
    /// Aligns the `AccessoryView`'s top edge to the cell's top edge.
    case cellTop
    
    /// Aligns the `AccessoryView`'s top edge to the `messageTopLabel`'s top edge.
    case messageLabelTop
    
    /// Aligns the `AccessoryView`'s top edge to the `MessageContainerView`'s top edge.
    case messageTop
    
    /// Aligns the `AccessoryView` center to the `MessageContainerView` center.
    case messageCenter
    
    /// Aligns the `AccessoryView`'s bottom edge to the `MessageContainerView`s bottom edge.
    case messageBottom
    
    /// Aligns the `AccessoryView`'s bottom edge to the cell's bottom edge.
    case cellBottom
}
