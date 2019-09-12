//
//  AssetModel.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2018/3/11.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import Foundation
import Photos.PHAsset

extension AssetModel {
    
    enum MediaType: Int {
        case photo = 0
        case livePhoto
        case gifPhoto
        case video
        case audio
    }
}

class AssetModel {
    
    var asset: PHAsset
    var isSelected: Bool = false
    var type: MediaType = .photo
    var timeLength: String?
    
    init(asset: PHAsset, type: MediaType, timeLength: String? = nil) {
        self.asset = asset
        self.type = type
        self.timeLength = timeLength
    }
}


