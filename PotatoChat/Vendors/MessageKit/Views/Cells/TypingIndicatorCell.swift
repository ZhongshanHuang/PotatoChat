//
//  TypingIndicatorCell.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/9/6.
//  Copyright © 2019 黄中山. All rights reserved.
//

import UIKit

/// A subclass of `MessageCollectionViewCell` used to display the typing indicator.
class TypingIndicatorCell: MessageCollectionViewCell {
    
    // MARK: - Subviews
    
    var insets = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
    
    let typingBubble = TypingBubble()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    func setupSubviews() {
        addSubview(typingBubble)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if typingBubble.isAnimating {
            typingBubble.stopAnimating()
        }
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        typingBubble.frame = bounds.inset(by: insets)
    }
    
}

