//
//  MediaItem.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/1/7.
//  Copyright © 2019 黄中山. All rights reserved.
//

import Foundation

protocol MediaItem {
    
//    var url: URL? { get }
//
//    var image: UIImage? { get }
    var thumbnailURL: URL { get } // thumbnail image
    var sourceURL: URL? { get } // high-quality image or video
    
    var size: CGSize { get }
}
