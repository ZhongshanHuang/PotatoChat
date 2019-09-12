//
//  PhotoPickerCell.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2018/3/21.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit
import Photos

class AssetCell: UICollectionViewCell {
    
    // MARK: - Properties[public]
    var assetModel: AssetModel?
    var selectBlockHander: ((Int) -> Void)?
    
    private var representedAssetIdentifier: String = ""
    private var imageRequestID: PHImageRequestID = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAssetModel(_ model: AssetModel) {
        self.assetModel = model
        
        selectBtn.isSelected = model.isSelected
        if model.type == .video {
            videoIcon.isHidden = false
            timeLabel.isHidden = false
            timeLabel.text = model.timeLength
        } else {
            videoIcon.isHidden = true
            timeLabel.isHidden = true
        }
        
//        representedAssetIdentifier = model.asset.localIdentifier
//        let requestID = PhotoPickerManager.shared.loadPhoto(with: model.asset, targetSize: bounds.size, completion: { (image, _, isDegraded) in
//            if self.representedAssetIdentifier == model.asset.localIdentifier {
//                self.imageView.image = image
//            }
//        })
//
//        if requestID != imageRequestID {
//            PHImageManager.default().cancelImageRequest(imageRequestID)
//        }
//
//        imageRequestID = requestID
        
        if imageRequestID != 0 {
            PHImageManager.default().cancelImageRequest(imageRequestID)
        }
        
        representedAssetIdentifier = model.asset.localIdentifier
        imageRequestID = PhotoPickerManager.shared.loadPhoto(with: model.asset, targetSize: bounds.size, completion: { (image, _, isDegraded) in
            if self.representedAssetIdentifier == model.asset.localIdentifier {
                self.imageView.image = image
            }
        })
    }
    
    // MARK: - Selector
    
    /// 选中按钮点击方法
    @objc private func selectBtnClick(_ sender: UIButton) {
        let isSelected = sender.isSelected
        
        // 图片不能超过9张提示
        if !isSelected, imagePicker.selectedModels.count >= 9 {
            let alertVC = UIAlertController(title: "图片选择", message: "不能超过9张图片", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "确认", style: .cancel, handler: nil)
            alertVC.addAction(cancel)
            imagePicker.present(alertVC, animated: true, completion: nil)
            return
        }
        
        sender.isSelected = !isSelected
        assetModel?.isSelected = sender.isSelected
        
        if sender.isSelected {
            imagePicker.selectedModels.append(assetModel!)
        } else {
            
            let index = imagePicker.selectedModels.firstIndex { (model) -> Bool in
                model.asset == self.assetModel?.asset
            }
            imagePicker.selectedModels.remove(at: index!)
        }
        
        selectBlockHander?(imagePicker.selectedModels.count)
    }
    
    // MARK: - Layout Subviews
    private func setupSubviews() {
        contentView.addSubview(imageView)
        contentView.addSubview(selectBtn)
        contentView.addSubview(videoIcon)
        contentView.addSubview(timeLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectBtn.frame = CGRect(x: bounds.width - 27, y: 0, width: 27, height: 27)
        imageView.frame = bounds
        videoIcon.frame = CGRect(x: 0, y: bounds.height - 16, width: 16, height: 16)
        timeLabel.frame = CGRect(x: videoIcon.frame.maxX + 5, y: videoIcon.frame.minY, width: bounds.width - videoIcon.frame.maxX - 5, height: videoIcon.frame.height)
    }

    
    // MARK: - Properties[private-lazy]
    private lazy var selectBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "photo_choose_def"), for: .normal)
        btn.setImage(UIImage(named: "photo_choose_sel"), for: .selected)
        btn.addTarget(self, action: #selector(selectBtnClick(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 11)
        label.textColor = UIColor.white
        label.textAlignment = .right
        label.text = "00:00"
        return label
    }()
    
    private lazy var videoIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "photo_video")
        return imageView
    }()
}


// MARK: - 获取 ImagePickerController
private extension AssetCell {
    
    var imagePicker: ImagePickerController! {
        var next = self.next
        while next != nil {
            if next is UIViewController {
                return (next as? UIViewController)?.navigationController as? ImagePickerController
            }
            next = next?.next
        }
        return nil
    }
}
