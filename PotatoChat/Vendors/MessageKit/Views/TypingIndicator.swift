//
//  TypingIndicator.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/9/6.
//  Copyright © 2019 黄中山. All rights reserved.
//

import UIKit

/// A `UIView` subclass that holds 3 dots which can be animated
class TypingIndicator: UIView {
    
    // MARK: - Properties
    
    /// The offset that each dot will transform by during the bounce animation
    public var bounceOffset: CGFloat = 2.5
    
    /// A convenience accessor for the `backgroundColor` of each dot
    open var dotColor: UIColor = UIColor.lightGray {
        didSet {
            dots.forEach { $0.backgroundColor = dotColor }
        }
    }
    
    /// A flag that determines if the bounce animation is added in `startAnimating()`
    public var isBounceEnabled: Bool = false
    
    /// A flag that determines if the opacity animation is added in `startAnimating()`
    public var isFadeEnabled: Bool = true
    
    /// A flag indicating the animation state
    public private(set) var isAnimating: Bool = false
    
    /// Keys for each animation layer
    private struct AnimationKeys {
        static let offset = "typingIndicator.offset"
        static let bounce = "typingIndicator.bounce"
        static let opacity = "typingIndicator.opacity"
    }
    
    /// The `CABasicAnimation` applied when `isBounceEnabled` is TRUE to move the dot to the correct
    /// initial offset
    var initialOffsetAnimationLayer: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.byValue = -bounceOffset
        animation.duration = 0.5
        animation.isRemovedOnCompletion = true
        return animation
    }
    
    /// The `CABasicAnimation` applied when `isBounceEnabled` is TRUE
    var bounceAnimationLayer: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.toValue = -bounceOffset
        animation.fromValue = bounceOffset
        animation.duration = 0.5
        animation.repeatCount = .infinity
        animation.autoreverses = true
        return animation
    }
    
    /// The `CABasicAnimation` applied when `isFadeEnabled` is TRUE
    var opacityAnimationLayer: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0.5
        animation.duration = 0.5
        animation.repeatCount = .infinity
        animation.autoreverses = true
        return animation
    }
    
    // MARK: - Subviews
    
    let stackView = UIStackView()
    
    let dots: [BubbleCircle] = {
        return [BubbleCircle(), BubbleCircle(), BubbleCircle()]
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    /// Sets up the view
    private func setupView() {
        dots.forEach {
            $0.backgroundColor = dotColor
            $0.heightAnchor.constraint(equalTo: $0.widthAnchor).isActive = true
            stackView.addArrangedSubview($0)
        }
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        addSubview(stackView)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stackView.frame = bounds
        stackView.spacing = bounds.width > 0 ? 5 : 0
    }
    
    // MARK: - Animation API
    
    /// Sets the state of the `TypingIndicator` to animating and applies animation layers
    func startAnimating() {
        defer { isAnimating = true }
        guard !isAnimating else { return }
        var delay: TimeInterval = 0
        for dot in dots {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let `self` = self else { return }
                if self.isBounceEnabled {
                    dot.layer.add(self.initialOffsetAnimationLayer, forKey: AnimationKeys.offset)
                    let bounceLayer = self.bounceAnimationLayer
                    bounceLayer.timeOffset = delay + 0.33
                    dot.layer.add(bounceLayer, forKey: AnimationKeys.bounce)
                }
                if self.isFadeEnabled {
                    dot.layer.add(self.opacityAnimationLayer, forKey: AnimationKeys.opacity)
                }
            }
            delay += 0.33
        }
    }
    
    /// Sets the state of the `TypingIndicator` to not animating and removes animation layers
    func stopAnimating() {
        defer { isAnimating = false }
        guard isAnimating else { return }
        dots.forEach {
            $0.layer.removeAnimation(forKey: AnimationKeys.bounce)
            $0.layer.removeAnimation(forKey: AnimationKeys.opacity)
        }
    }
    
}
