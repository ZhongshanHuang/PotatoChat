//
//  AvatarView.swift
//  MessageExample
//
//  Created by 黄中山 on 2017/11/26.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import UIKit

class AvatarView: UIImageView {
    
    // MARK: - Properties

    var initials: String? {
        didSet {
            setImageFrom(initials: initials)
        }
    }
    
    var placeholderFont: UIFont = UIFont.preferredFont(forTextStyle: .caption1) {
        didSet {
            setImageFrom(initials: initials)
        }
    }
    
    var placeholderTextColor: UIColor = UIColor.white {
        didSet {
            setImageFrom(initials: initials)
        }
    }
    
    var fontMininumScaleFactor: CGFloat = 0.5
    
    var adjustsFontSizeToFitWidth: Bool = true
    
    private var mininumFontSize: CGFloat {
        return placeholderFont.pointSize * fontMininumScaleFactor
    }
    
    private var radius: CGFloat?
    
    // MARK: - Overridden Properties
    
    override var frame: CGRect {
        didSet {
            setCorner(radius: radius)
        }
    }
    
    override var bounds: CGRect {
        didSet {
            setCorner(radius: radius)
        }
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareView()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareView()
    }
    
    private func setImageFrom(initials: String?) {
        guard let initials = initials else { return }
        image = getImageFrom(initials: initials)
    }
    
    private func getImageFrom(initials: String) -> UIImage {
        let width = frame.width
        let height = frame.height
        if width == 0 || height == 0 { return UIImage() }
        var font = placeholderFont
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()
        
        //// Text Drawing
        let textRect = calculatetextRect(outerViewWidth: width, outerViewHeight: height)
        if adjustsFontSizeToFitWidth, initials.width(considering: textRect.height, and: font) > textRect.width {
            let newFontSize = calculateFontSize(text: initials, font: font, width: textRect.width, height: textRect.height)
            font = placeholderFont.withSize(newFontSize)
        }
        
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center
        let textFontAttributes: [NSAttributedString.Key: Any] = [.font: font,
                                                                 .foregroundColor: placeholderTextColor,
                                                                 .paragraphStyle: textStyle]
        
        let textHeight: CGFloat = initials.boundingRect(with: CGSize(width: textRect.width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: textFontAttributes, context: nil).height
        
        context?.saveGState()
        context?.clip(to: textRect)
        initials.draw(in: CGRect(x: textRect.minX, y: textRect.minY + (textRect.height - textHeight) / 2, width: textRect.width, height: textHeight), withAttributes: textFontAttributes)
        context?.restoreGState()
        guard let renderedImage = UIGraphicsGetImageFromCurrentImageContext() else { assertionFailure("Could not create image from context"); return UIImage()}
        return renderedImage
    }
    
    private func calculateFontSize(text: String, font: UIFont, width: CGFloat, height: CGFloat) -> CGFloat {
        if text.width(considering: height, and: font) > width {
            let newFont = font.withSize(font.pointSize - 1)
            if newFont.pointSize > mininumFontSize {
                return font.pointSize
            } else {
                return calculateFontSize(text:text, font: font, width: width, height: height)
            }
        }
        return font.pointSize
    }
    
    private func calculatetextRect(outerViewWidth: CGFloat, outerViewHeight: CGFloat) -> CGRect {
        guard outerViewWidth > 0 else { return CGRect.zero }
        
        let shortEdge = min(outerViewWidth, outerViewHeight)
        // Converts degree to radian degree and calculate the
        // Assumes, it is a perfect circle based on the shorter part of ellipsoid
        // calculate a rectangle
        let w = shortEdge * sin(CGFloat(45).degreesToRadians) * 2
        let h = shortEdge * cos(CGFloat(45).degreesToRadians) * 2
        let startX = (outerViewWidth - w)/2
        let startY = (outerViewHeight - h)/2
        // In case the font exactly fits to the region, put 2 pixel both left and right
        return CGRect(x: startX+2, y: startY, width: w-4, height: h)
    }
    
    private func prepareView() {
        backgroundColor = UIColor.gray
        contentMode = .scaleAspectFill
        clipsToBounds = true
        setCorner(radius: 5)
    }
    
    
    // MARK: - Open setters
    
    func set(avatar: Avatar) {
        if let image = avatar.image {
            self.image = image
        } else {
            setImageFrom(initials: avatar.initials)
        }
    }
    
    func setCorner(radius: CGFloat?) {
        guard let radius = radius else {
            //if corner radius not set default to Circle
            let cornerRadius = min(frame.width, frame.height)
            layer.cornerRadius = cornerRadius/2
            return
        }
        self.radius = radius
        layer.cornerRadius = radius
    }
    
}

private extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
