//
//  ImagePickerController.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2018/3/11.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit
import Photos.PHAsset

@objc protocol ImagePickerControllerDelegate {
    
    // 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的handle
    @objc optional func imagePickerController(_ picker: ImagePickerController, didFinishPickingPhotos photos: Array<UIImage>, sourceAssets: Array<PHAsset>, isOriginal: Bool)
}

class ImagePickerController: UINavigationController {
    

    // MARK: - Properties[private]
    private var tipLabel: UILabel?
    private var settingBtn: UIButton?
    private var timer: Timer?
    
    // MARK: allowPickingVideo
    init(maxSelectableImagesCount: Int = 9, columnCount: Int = 4, delegate: ImagePickerControllerDelegate) {
      
        self.pickerDelegate = delegate
        self.columnCount = columnCount
        self.maxSelectableImagesCount = maxSelectableImagesCount
        
        let albumVC = AlbumPickerViewController()
        albumVC.isFirstAppear = true
        albumVC.columnCount = columnCount
        super.init(nibName: nil, bundle: nil)
        pushViewController(albumVC, animated: false)
        
        // 如果不允许访问相册
        if PhotoPickerManager.shared.authorizationStatusAuthorized() == false {
            tipLabel = UILabel()
            tipLabel?.frame = CGRect(x: 8, y: 120, width: view.bounds.width - 16, height: 60)
            tipLabel?.textAlignment = .center
            tipLabel?.numberOfLines = 0
            tipLabel?.font = UIFont.systemFont(ofSize: 16)
            tipLabel?.textColor = UIColor.black
            
            var tipText: String
            if let appInfo = Bundle.main.infoDictionary, let appName = appInfo["CFBundleDisplayName"] as? String {
                tipText = "请允许\(appName)访问您的相册 路径:\"设置->隐私->相册\""
            } else {
                tipText = "请允许程序访问您的相册 路径:\"设置->隐私->相册\""
            }
            

            tipLabel?.text = tipText
            view.addSubview(tipLabel!)
            
            settingBtn = UIButton(type: .system)
            settingBtn?.setTitle("设置", for: .normal)
            settingBtn?.frame = CGRect(x: 0, y: 180, width: view.bounds.width, height: 44)
            settingBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            settingBtn?.addTarget(self, action: #selector(settingBtnClick), for: .touchUpInside)
            view.addSubview(settingBtn!)
            
            if PhotoPickerManager.autorizationStatus() == .notDetermined {
                timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(observeAuthrizationStatusChange), userInfo: nil, repeats: false)
            }
        } else {
            pushPhotoPickerViewController()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 打开设置界面
    @objc private func settingBtnClick() {
        if #available(iOS 10, *) {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
        }
    }
    
    /// 定时检查是否认证成功
    @objc
    private func observeAuthrizationStatusChange() {
        timer?.invalidate()
        timer = nil
        if PhotoPickerManager.autorizationStatus() == .notDetermined {
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(observeAuthrizationStatusChange), userInfo: nil, repeats: false)
            return
        }
        
        if PhotoPickerManager.shared.authorizationStatusAuthorized() {
            tipLabel?.removeFromSuperview()
            tipLabel = nil
            settingBtn?.removeFromSuperview()
            settingBtn = nil
            
            pushPhotoPickerViewController()
            
            if let albumPickerVC = visibleViewController as? AlbumPickerViewController {
                albumPickerVC.fetchAlbums()
            }
        }
    }
    
    /// push vc
    func pushPhotoPickerViewController() {
            let photoVC = PhotoPickerViewController()
            photoVC.columnCount = columnCount
            self.pushViewController(photoVC, animated: true)
    }
    
    
    // MARK: - Properties

    weak var pickerDelegate: ImagePickerControllerDelegate?
    
    /// 相册的列数
    var columnCount: Int = 4
    
    /// 相册照片的间隙
    var margin: CGFloat = 8
    
    /// 最多可以选择照片的数量
    var maxSelectableImagesCount: Int = 9
    
    /// 按照修改时间的升序排序
    var sortAscendingByModificationDate: Bool = true
    
    /// 默认为YES，如果设置为NO,原图按钮将隐藏，用户不能选择发送原图
    var allowPickingOriginalPhoto: Bool = true
    
    /// 默认为YES，如果设置为NO,用户将不能选择视频
    var allowPickingVideo = true
    
    /// Default is NO / 默认为NO，为YES时可以多选视频/gif图片，和照片共享最大可选张数maxImagesCount的限制
    var allowPickingMultipleVideo: Bool = true
    
    /// 默认为NO，如果设置为YES,用户可以选择gif图片
    var allowPickingGif: Bool = true
    
    /// 用户选中过的图片数组
    var selectedModels: Array<AssetModel> = []

    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    private func setupSubviews() {
        view.backgroundColor = UIColor.white
        navigationBar.barStyle = .black
        navigationBar.isTranslucent = true
        navigationBar.barTintColor = UIColor(red: 34/255.0, green: 34/255.0, blue: 34/255.0, alpha: 1.0)
        navigationBar.tintColor = UIColor.white
        // 手势代理设为自己，处理手势冲突
        interactivePopGestureRecognizer?.delegate = self
    }
}



// MARK: - UIGestureRecognizerDelegate

extension ImagePickerController: UIGestureRecognizerDelegate {
    
    // 防止右滑手势将最底层视图控制器pop
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if viewControllers.count > 1 {
            return true
        } else {
            return false
        }
    }
    
    // collectionView手势 与 右滑同时触发的时候使 collectionView手势无效
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIScreenEdgePanGestureRecognizer
    }
}
