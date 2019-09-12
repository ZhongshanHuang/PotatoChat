//
//  MessageContainerView.swift
//  MessageExample
//
//  Created by 黄中山 on 2017/11/26.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import UIKit

class MessageContainerView: UIImageView {

    // MARK: - Properties
    
    private let imageMask = UIImageView()
    
    override var frame: CGRect {
        didSet {
            sizeMaskToView()
        }
    }
    
    var style: MessageStyle = .none {
        didSet {
            applyMessageStyle()
        }
    }
    
    // MARK: - Methods
    
    private func sizeMaskToView() {
        switch style {
        case .none, .custom:
            break
        case .bubble, .bubbleTail, .bubbleOutline, .bubbleTailOutline:
            imageMask.frame = bounds
        }
    }
    
    private func applyMessageStyle() {
        switch style {
        case .bubble, .bubbleTail:
            imageMask.image = style.image
            sizeMaskToView()
            mask = imageMask
            image = nil
        case .bubbleOutline(let color):
            let bubbleStyle: MessageStyle = .bubble
            imageMask.image = bubbleStyle.image
            sizeMaskToView()
            mask = imageMask
            image = style.image?.withRenderingMode(.alwaysTemplate)
            tintColor = color
        case .bubbleTailOutline(let color, let tail):
            let bubbleStyle: MessageStyle = .bubbleTail(tail)
            imageMask.image = bubbleStyle.image
            sizeMaskToView()
            mask = imageMask
            image = style.image?.withRenderingMode(.alwaysTemplate)
            tintColor = color
        case .none:
            mask = nil
            image = nil
            tintColor = nil
        case .custom(let configurationClosure):
            mask = nil
            image = nil
            tintColor = nil
            configurationClosure(self)
        }
    }
}
