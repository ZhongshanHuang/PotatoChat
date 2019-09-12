//
//  PhotoPickerManager.swift
//
//
//  Created by 黄中山 on 2018/3/11.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import Foundation
import Photos

class PhotoPickerManager {

    // MARK: - 单例模式
    static let shared = PhotoPickerManager()
    private init() {}
    
    private var screenScale: CGFloat = 2
    
    // MARK: - Properties
    
    weak var pickerDelegate: ImagePickerControllerDelegate?
    var sortAscendingByModificationDate: Bool = true
    
    // MARK: - Authorize
    
    /// Return true if Authorized 返回YES如果得到了授权
    func authorizationStatusAuthorized() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            /**
             * 当某些情况下AuthorizationStatus == .notDetermined时，无法弹出系统首次使用的授权alertView，系统应用设置里亦没有相册的设置，此时将无法使用，故作以下操作，弹出系统首次使用的授权alertView
             */

            requestAuthorization(completion: nil)
        }
        return status == .authorized
    }
    
    func requestAuthorization(completion: (() -> Void)?) {
        DispatchQueue.global(qos: .default).async {
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.async {
                    completion?()
                }
            })
        }
    }
    
    static func autorizationStatus() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
    
    // MARK: - 获取资源
    
    /// Load CameraRoll Album 获取相册
    func loadCameraRollAlbum(allowPickingVideo: Bool, needFetchAssets: Bool, completion: @escaping (AlbumModel) -> Void) {
        let option = PHFetchOptions()
        if !allowPickingVideo {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        }
        
        if !sortAscendingByModificationDate {
            option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: sortAscendingByModificationDate)]
        }
        
        let colFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        colFetchResult.enumerateObjects { (collection, _, stop) in
            // 过滤空相册
            if collection.estimatedAssetCount <= 0 { return }
            
            if self.isCameraRollAlbum(metadata: collection) {
                let fetchResult = PHAsset.fetchAssets(in: collection, options: option)
                let albumModel = self.creatAlbumModel(with: fetchResult, name: collection.localizedTitle!, isCameraRoll: true, needFetchAssets: needFetchAssets)

                completion(albumModel)
                stop.pointee = true
            }
        }
        
    }
    
    /// Load Albums 相册列表
    func loadAllAlbums(allowPickingVideo: Bool, needFetchAssets: Bool, completion: (Array<AlbumModel>) -> Void) {
        var albumArr = Array<AlbumModel>()

        let options = PHFetchOptions()
        if !allowPickingVideo {
            options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        }

        // 按资源创建的倒序
        if !sortAscendingByModificationDate {
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: sortAscendingByModificationDate)]
        }
        
        // 自己建立的相册
//        PHCollection.fetchTopLevelUserCollections(with: nil)
        let topLevelUser = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        // 相机拍摄的相册
        let smartAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        // 从别处同步过来的相册
        let syncedAlbum = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumSyncedAlbum, options: nil)
        // 截屏相册
        let screenshotAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil)
        // 视频相册
        let videoAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: nil)
        // 用户标记喜欢的照片
        let favoriteAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: nil)
        
        let allAlbums = [topLevelUser, smartAlbum, syncedAlbum, screenshotAlbum, videoAlbum, favoriteAlbum]
        
        for fetchResult in allAlbums {
            fetchResult.enumerateObjects { (collection, _, stop) in
                // 过滤空相册
                if collection.estimatedAssetCount <= 0 { return }
                let result = PHAsset.fetchAssets(in: collection, options: options)
                if result.count <= 0 { return }
                
                // 过滤隐藏的 & 最近删除的相册
                if collection.assetCollectionSubtype == .smartAlbumAllHidden || collection.assetCollectionSubtype.rawValue == 1000000201 { return }
                
                if self.isCameraRollAlbum(metadata: collection) {
                    let model = self.creatAlbumModel(with: result, name: collection.localizedTitle!, isCameraRoll: true, needFetchAssets: needFetchAssets)
                    albumArr.insert(model, at: 0)
                } else {
                    let model = self.creatAlbumModel(with: result, name: collection.localizedTitle!, isCameraRoll: false, needFetchAssets: needFetchAssets)
                    albumArr.append(model)
                }
            }
        }
        completion(albumArr)
    }
    
    /// Load Assets 获得Asset数组
    func loadAssets(from fetchResult: PHFetchResult<PHAsset>, completion: (Array<AssetModel>) -> Void) {
        var photoArr = Array<AssetModel>()
        
        fetchResult.enumerateObjects { (asset, _, _) in
            let model = self.creatAssetModel(with: asset)
            if let model = model {
                photoArr.append(model)
            }
        }
        completion(photoArr)
    }
    
    /// Load asset at index 获取下标为index的单个照片
    func loadAsset(from fetchResult: PHFetchResult<PHAsset>, at index: Int, completion: (AssetModel?) -> Void) {
        if index >= fetchResult.count {
            completion(nil)
        } else {
            let asset = fetchResult[index]
            let model = creatAssetModel(with: asset)
            completion(model)
        }
    }
    
    /// Load Photo 获取照片 completion会调用多次，原始图片只调用一次
    @discardableResult
    func loadPhoto(with asset: PHAsset, targetSize: CGSize = .zero, isOriginal: Bool = false, completion: @escaping (UIImage?, Dictionary<AnyHashable, Any>?, Bool) -> Void) -> PHImageRequestID {
        
        let options = PHImageRequestOptions()
        var targetSize = targetSize
        
        // 如果是原始图片
        if isOriginal {
            options.resizeMode = .exact // 尺寸精确
            options.deliveryMode = .highQualityFormat // 图片质量高
            targetSize = PHImageManagerMaximumSize // 原始尺寸
        } else {
            options.deliveryMode = .opportunistic // 图片质量 均衡
            options.resizeMode = .fast // 图片缩放比例 接近即可
            targetSize = CGSize(width: targetSize.width * screenScale, height: targetSize.height * screenScale)
            
            if targetSize == .zero {
                targetSize = CGSize(width: CGFloat(asset.pixelWidth) / UIScreen.main.scale * screenScale,
                                    height: CGFloat(asset.pixelHeight) / UIScreen.main.scale * screenScale)
            }
        }
        
        return PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (result, info) in
            var isDegraded: Bool = true
            if let info = info, let degraded = info[PHImageResultIsDegradedKey] as? Bool {
                isDegraded = degraded
            }
            completion(result, info, isDegraded)
        }
    }


    /// Load posetImage / 获取封面图
    func loadPosterImage(with albumMode: AlbumModel, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) -> PHImageRequestID {
        var asset: PHAsset?
        if sortAscendingByModificationDate {
            asset = albumMode.result?.lastObject
        } else {
            asset = albumMode.result?.firstObject
        }
        
        if let asset = asset {
            return loadPhoto(with: asset, targetSize: targetSize) { (result, _, _) in
                completion(result)
            }
        } else {
            completion(nil)
            return PHInvalidImageRequestID
        }
    }
    
    /// 加载asset的原始数据
    /// 该方法中，completion只会走一次
    @discardableResult
    func loadPhotoData(with asset: PHAsset, completion: @escaping (Data?, Dictionary<AnyHashable, Any>?) -> Void) -> PHImageRequestID {
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        options.deliveryMode = .highQualityFormat
        if let fileName = (asset.value(forKey: "filename") as? String), fileName.hasSuffix("GIF") {
            options.version = .original
        }
        
        return PHImageManager.default().requestImageData(for: asset, options: options) { (imageData, dataUTI, orientation, info) in
            completion(imageData, info)
        }
    }
    
    /// Save Photo
    func saveImage(_ image: UIImage, location: CLLocation? = nil, completion: ((Error?) -> Void)?) {
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            request.location = location
            request.creationDate = Date()
        }) { (success, error) in
            if let error = error {
                debugPrint("保存照片出错: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    /// Get Video 获得视频
    func loadVideo(with asset: PHAsset, progressHandler: ((Double, Error, UnsafeMutablePointer<ObjCBool>, Dictionary<AnyHashable, Any>?) -> Void)? = nil, completion: @escaping (AVPlayerItem?, Dictionary<AnyHashable, Any>?) -> Void) {
        let options = PHVideoRequestOptions()
        PHImageManager.default().requestPlayerItem(forVideo: asset, options: options, resultHandler: completion)
    }
    
    /// Save video
    func saveVideo(url: URL, location: CLLocation? = nil, completion: ((PHAsset?, Error?) -> Void)?) {
        var localIdentifier: String?
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            localIdentifier = request?.placeholderForCreatedAsset?.localIdentifier
            request?.location = location
            request?.creationDate = Date()
        }) { (sucess, error) in
            if sucess {
                let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier!], options: nil).firstObject
                completion?(asset, nil)
            } else {
                completion?(nil, error)
            }
        }
    }
    
    
    /// Load Photo Bytes 获取一组照片大小
    func loadPhotosBytes(from models: Array<AssetModel>, completion: @escaping (String) -> Void) {
        if models.isEmpty {
            completion("0B")
            return
        }
        
        var dataLen: Int = 0
        var assetCount: Int = 0
        
        for model in models {
            let options = PHImageRequestOptions()
            options.resizeMode = .fast
            if model.type == .gifPhoto {
                options.version = .original
            }
            
            
            PHImageManager.default().requestImageData(for: model.asset, options: options) { (imageData, dataUTI, orientation, info) in
                if model.type != .video {
                    dataLen += imageData!.count
                }
                assetCount += 1
                if assetCount >= models.count {
                    let bytes = self.formatBytesString(with: dataLen)
                    completion(bytes)
                }
            }
        }
    }
    
    func isCameraRollAlbum(metadata: PHAssetCollection) -> Bool {
        var versionStr = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "")
        if versionStr.count <= 1 {
            versionStr += "00"
        } else if versionStr.count <= 2 {
            versionStr += "0"
        }
        let version = Int(versionStr)!
        // 8.0.0～8.0.2系统，拍照后的图片保存在最近添加中
        if version >= 800 && version <= 802 {
            return metadata.assetCollectionSubtype == .smartAlbumRecentlyAdded
        } else {
            return metadata.assetCollectionSubtype == .smartAlbumUserLibrary
        }
    }
    
    
    // MARK: - Methods[Private]
    
    private func creatAlbumModel(with result: PHFetchResult<PHAsset>, name: String, isCameraRoll: Bool, needFetchAssets: Bool) -> AlbumModel {
        let model = AlbumModel()
        model.set(result: result, needFetchAssets: needFetchAssets)
        model.name = name
        model.isCameraRoll = isCameraRoll
        model.count = result.count
        
        return model
    }
    
    private func creatAssetModel(with asset: PHAsset) -> AssetModel? {
        let type = assetType(asset)
        
        let timeLen = (type == .video ? Int(asset.duration) : 0)
        let formartTimeStr = formatTimeString(with: timeLen)
        return AssetModel(asset: asset, type: type, timeLength: formartTimeStr)
    }
    
    private func assetType(_ asset: PHAsset) -> AssetModel.MediaType {
        switch asset.mediaType {
        case .video:
            return .video
        case .audio:
            return .audio
        case .image:
            if (asset.value(forKey: "filename") as! String).hasSuffix("GIF") {
                return .gifPhoto
            } else if #available(iOS 9.1, *), asset.mediaSubtypes == .photoLive {
                return .livePhoto
            } else {
                return .photo
            }
        default:
            return .photo
        }
    }
    
    /// 将时间秒数转换成自定义格式化字符串
    private func formatTimeString(with timeInterval: Int) -> String {
        var timeStr: String
        
        if timeInterval < 60 {
            timeStr = String(format: "0:%02d", timeInterval)
        } else {
            let min = timeInterval / 60
            let sec = timeInterval - min*60
            timeStr = String(format: "%d:%02d", min, sec)
        }
        return timeStr
    }
    
    /// 将字节数转换成自定义格式化字符串
    private func formatBytesString(with bytes: Int) -> String {
        var bytesStr: String
        let count = Double(bytes)
        if count > 0.1*(1024*1024) {
            bytesStr = String(format: "%0.1fM" , count/1024/1024)
        } else if count >= 1024 {
            bytesStr = String(format: "%0.0fK", count/1024)
        } else {
            bytesStr = String(format: "%0.0fB", count)
        }
        return bytesStr
    }
}
