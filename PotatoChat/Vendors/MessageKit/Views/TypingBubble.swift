//
//  TypingBubble.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/9/6.
//  Copyright © 2019 黄中山. All rights reserved.
//

import UIKit

/// A subclass of `UIView` that mimics the iMessage typing bubble
class TypingBubble: UIView {
    
    // MARK: - Properties
    
    var isPulseEnabled: Bool = true
    
    private(set) var isAnimating: Bool = false
    
    override var backgroundColor: UIColor? {
        set {
            [contentBubble, cornerBubble, tinyBubble].forEach { $0.backgroundColor = newValue }
        }
        get {
            return contentBubble.backgroundColor
        }
    }
    
    private struct AnimationKeys {
        static let pulse = "typingBubble.pulse"
    }
    
    // MARK: - Subviews
    
    /// The indicator used to display the typing animation.
    let typingIndicator = TypingIndicator()
    
    let contentBubble = UIView()
    
    let cornerBubble = BubbleCircle()
    
    let tinyBubble = BubbleCircle()
    
    // MARK: - Animation Layers
    
    var contentPulseAnimationLayer: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1
        animation.toValue = 1.04
        animation.duration = 1
        animation.repeatCount = .infinity
        animation.autoreverses = true
        return animation
    }
    
    var circlePulseAnimationLayer: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1
        animation.toValue = 1.1
        animation.duration = 0.5
        animation.repeatCount = .infinity
        animation.autoreverses = true
        return animation
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    func setupSubviews() {
        addSubview(tinyBubble)
        addSubview(cornerBubble)
        addSubview(contentBubble)
        contentBubble.addSubview(typingIndicator)
        backgroundColor = .incomingGray
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // To maintain the iMessage like bubble the width:height ratio of the frame
        // must be close to 1.65
        let ratio = bounds.width / bounds.height
        let extraRightInset = bounds.width - 1.65/ratio*bounds.width
        
        let tinyBubbleRadius: CGFloat = bounds.height / 6
        tinyBubble.frame = CGRect(x: 0,
                                  y: bounds.height - tinyBubbleRadius,
                                  width: tinyBubbleRadius,
                                  height: tinyBubbleRadius)
        
        let cornerBubbleRadius = tinyBubbleRadius * 2
        let offset: CGFloat = tinyBubbleRadius / 6
        cornerBubble.frame = CGRect(x: tinyBubbleRadius - offset,
                                    y: bounds.height - (1.5 * cornerBubbleRadius) + offset,
                                    width: cornerBubbleRadius,
                                    height: cornerBubbleRadius)
        
        let contentBubbleFrame = CGRect(x: tinyBubbleRadius + offset,
                                        y: 0,
                                        width: bounds.width - (tinyBubbleRadius + offset) - extraRightInset,
                                        height: bounds.height - (tinyBubbleRadius + offset))
        let contentBubbleFrameCornerRadius = contentBubbleFrame.height / 2
        
        contentBubble.frame = contentBubbleFrame
        contentBubble.layer.cornerRadius = contentBubbleFrameCornerRadius
        
        let insets = UIEdgeInsets(top: offset, left: contentBubbleFrameCornerRadius / 1.25, bottom: offset, right: contentBubbleFrameCornerRadius / 1.25)
        typingIndicator.frame = contentBubble.bounds.inset(by: insets)
    }
    
    // MARK: - Animation API
    
    func startAnimating() {
        defer { isAnimating = true }
        guard !isAnimating else { return }
        typingIndicator.startAnimating()
        if isPulseEnabled {
            contentBubble.layer.add(contentPulseAnimationLayer, forKey: AnimationKeys.pulse)
            [cornerBubble, tinyBubble].forEach { $0.layer.add(circlePulseAnimationLayer, forKey: AnimationKeys.pulse) }
        }
    }
    
    func stopAnimating() {
        defer { isAnimating = false }
        guard isAnimating else { return }
        typingIndicator.stopAnimating()
        [contentBubble, cornerBubble, tinyBubble].forEach { $0.layer.removeAnimation(forKey: AnimationKeys.pulse) }
    }
    
}

