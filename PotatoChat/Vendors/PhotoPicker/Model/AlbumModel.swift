//
//  AlbumModel.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2018/3/11.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import Foundation
import Photos.PHFetchResult

class AlbumModel {
    var name: String = ""
    var count: Int = 0
    var result: PHFetchResult<PHAsset>?
    
    var models: Array<AssetModel> = []

    var isCameraRoll: Bool = false
    
    func set(result: PHFetchResult<PHAsset>, needFetchAssets: Bool) {
        self.result = result

        if needFetchAssets {
            PhotoPickerManager.shared.loadAssets(from: result) { (assetModels) in
                models = assetModels
            }
        }
    }
    
}
