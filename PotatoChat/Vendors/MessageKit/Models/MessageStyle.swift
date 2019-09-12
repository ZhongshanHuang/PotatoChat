//
//  MessageStyle.swift
//  MessageExample
//
//  Created by 黄中山 on 2017/11/26.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import UIKit

enum MessageStyle {
    
    // MARK: - TailCorner
    enum TailCorner: String {
        
        case left
        case right
        
        var imageOrientation: UIImage.Orientation {
            switch self {
            case .right:
                return .up
            case .left:
                return .upMirrored
            }
        }
    }
    
    // MARK: - TailStyle
//    enum TailStyle {
//
//        case curved
//        case pointedEdge
//
//        var imageNameSuffix: String {
//            switch self {
//            case .curved:
//                return "_tail_v2"
//            case .pointedEdge:
//                return "_tail_v1"
//            }
//        }
//    }
    
    // MARK: - MessageStyle
    
    case none
    case bubble
    case bubbleOutline(UIColor)
    case bubbleTail(TailCorner)
    case bubbleTailOutline(UIColor, TailCorner)
    case custom((MessageContainerView) -> Void)
    
    // MARK: - Public
    
    var image: UIImage? {
        guard let imageCacheKey = imageCacheKey else { return nil }

        let cache = MessageStyle.bubbleImageCache
        if let cachedImage = cache.object(forKey: imageCacheKey as NSString) {
            return cachedImage
        }
        
        guard var image: UIImage = UIImage(contentsOfFile: imagePath!) else { return nil }
        
        switch self {
        case .none, .custom:
            return nil
        case .bubble, .bubbleOutline:
            break
        case .bubbleTail(let corner), .bubbleTailOutline(_, let corner):
            guard let cgImage = image.cgImage else { return nil }
            image = UIImage(cgImage: cgImage, scale: image.scale, orientation: corner.imageOrientation)
        }
        
        let stretchedImage = stretch(image)
        cache.setObject(stretchedImage, forKey: imageCacheKey as NSString)
        
        return stretchedImage
    }
    
    static let bubbleImageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.name = "com.messagekit.MessageKit.bubbleImageCache"
        return cache
    }()
    
    // MARK: - Private
    
    private var imageCacheKey: String? {
        guard let imageName = imageName else { return nil }
        
        switch self {
        case .bubble, .bubbleOutline:
            return imageName
        case .bubbleTail(let corner), .bubbleTailOutline(_, let corner):
            return imageName + "_" + corner.rawValue
        default:
            return nil
        }
    }
    
    private var imageName: String? {
        switch self {
        case .bubble:
            return "bubble"
        case .bubbleOutline:
            return nil
        case .bubbleTail:
            return "bubble_tail"
        case .bubbleTailOutline:
            return nil
        case .none, .custom:
            return nil
        }
    }
    
    var imagePath: String? {
        guard let imageName = imageName else { return nil }
        return Bundle.main.path(forResource: imageName, ofType: "png", inDirectory: nil)
    }

    private func stretch(_ image: UIImage) -> UIImage {
        let size = image.size
        let capInsets = UIEdgeInsets(top: size.height - 5, left: size.width/2 - 1, bottom: 6, right: size.width/2 + 1)
        return image.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
    }
}
