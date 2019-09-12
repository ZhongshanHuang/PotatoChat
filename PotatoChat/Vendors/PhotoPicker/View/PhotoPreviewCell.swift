//
//  PhotoPreviewCell.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2018/4/1.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit
import Photos

class PhotoPreviewCell: UICollectionViewCell {
    
    // MARK: - Properties[public]
    var assetModel: AssetModel?
    
    private let padding: CGFloat = 8
    private var representedAssetIdentifier: String = ""
    private var imageRequestID: PHImageRequestID = 0
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        
    }
    
    private func setupSubviews() {
        backgroundColor = UIColor.black
        scrollView.addSubview(imageView)
        scrollView.delegate = self
        contentView.addSubview(scrollView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        scrollView.zoomScale = 1.0
        scrollView.contentOffset = .zero
        scrollView.contentInset = .zero
        scrollView.contentSize = .zero
    }
    
    // MARK: - Methods[public]
    
    /// 重置scrollView的状态
    func resetScale() {
        scrollView.zoomScale = 1.0
    }
    
    /// 放大或者缩小imageView
    func scrollViewZoom(in touchPoint: CGPoint) {
        // 如果当前已经放到最大，则恢复原样
        if scrollView.zoomScale == scrollView.maximumZoomScale {
            scrollView.setZoomScale(1.0, animated: true)
            return
        }
        
        // 放大指定区域
        let zoomRect = CGRect(x: touchPoint.x - 40, y: touchPoint.y - 40, width: 80, height: 80)
        scrollView.zoom(to: zoomRect, animated: true)
    }
    
    func setAssetModel(_ model: AssetModel) {
        self.assetModel = model
        
//        representedAssetIdentifier = model.asset.localIdentifier
//        let requestID = PhotoPickerManager.shared.loadPhoto(with: model.asset, targetSize: UIScreen.main.bounds.size, completion: { (image, _, isDegraded) in
//            if self.representedAssetIdentifier == model.asset.localIdentifier {
//                self.imageView.image = image
//            }
//            if !isDegraded {
//                self.setPosition(accordingTo: image!.size)
//            }
//        })
//
//        // 可以降低快速滑动时候的内存
//        if requestID != imageRequestID && imageRequestID != 0 {
//            PHImageManager.default().cancelImageRequest(imageRequestID)
//        }
//
//        imageRequestID = requestID
        
        if imageRequestID != 0 {
            PHImageManager.default().cancelImageRequest(imageRequestID)
        }
        
        representedAssetIdentifier = model.asset.localIdentifier
        imageRequestID = PhotoPickerManager.shared.loadPhoto(with: model.asset, targetSize: UIScreen.main.bounds.size, completion: { (image, _, isDegraded) in
            if self.representedAssetIdentifier == model.asset.localIdentifier {
                self.imageView.image = image
            }
            if !isDegraded {
                self.setPosition(accordingTo: image!.size)
            }
        })
    }

    
    /// 根据图片大小设置imageView的大小，并且设置scrollView的contentInset，使imageView处在中间
    private func setPosition(accordingTo size: CGSize) {
        let w = scrollView.bounds.width
        let h = w * (size.height / size.width)
        
        if h < scrollView.bounds.height {
            // 设置内容间距
            let top = (scrollView.bounds.height - h) / 2
            scrollView.contentInset.top = top
        } else {
            scrollView.contentSize = CGSize(width: w, height: h)
        }
        
        imageView.frame = CGRect(x: 0, y: 0, width: w, height: h)
    }
    
    // MARK: - Layout Subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var rect = bounds
        rect.size.width -= padding
        scrollView.frame = rect
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black
        return imageView
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.black
        scrollView.maximumZoomScale = 2
        scrollView.minimumZoomScale = 1
        scrollView.bouncesZoom = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        if #available(iOS 11, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        return scrollView
    }()
    
}

// MARK: - UIScrollViewDelegate
extension PhotoPreviewCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // 当scrollView缩放时，imageView的transform发生变化，会导致frame发生变化，但bounds不会改变，所以必须用frame计算
        let offsetX = (scrollView.bounds.width - imageView.frame.width) / 2
        let offsetY = (scrollView.bounds.height - imageView.frame.height) / 2
        
        scrollView.contentInset = UIEdgeInsets(top: (offsetY < 0 ? 0 : offsetY),
                                               left: (offsetX < 0 ? 0 : offsetX),
                                               bottom: 0,
                                               right: 0)
    }
}


// MARK: - imagePicker
extension PhotoPreviewCell {
    
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
