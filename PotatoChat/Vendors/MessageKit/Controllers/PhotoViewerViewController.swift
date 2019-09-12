//
//  PhotoViewController.swift
//  WeChat
//
//  Created by 黄中山 on 2018/1/15.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoViewerViewController: UIViewController {
    // MARK: - Properpties[Public]

    var indexPath: IndexPath!
    
    var image: UIImage? {
        get { return imageView.image }
        set {
            guard let image = newValue else { return }
            DispatchQueue.main.async {
                self.setPosition(accordingTo: image.size)
                self.imageView.image = image
            }
        }
    }

    var imageUrl: URL? {
        didSet {
            guard let url = imageUrl else { return }
            imageView.kf.setImage(with: url) { (result) in
                switch result {
                case .success(let value):
                    self.setPosition(accordingTo: value.image.size)
                case .failure(let error):
                    debugPrint(error)
                }
            }
        }
    }
    
    // 根据原图大小设置显示效果
    private func setPosition(accordingTo size: CGSize) {

        let displaySize = CGSize(width: scrollView.bounds.width, height: size.height * scrollView.bounds.width/size.width)
        imageView.frame = CGRect(origin: .zero, size: displaySize)
        
        // 设置间距
        if displaySize.height <= scrollView.bounds.height {
            let offset = (scrollView.bounds.height - displaySize.height) / 2
            scrollView.contentInset.top = offset
        } else {
            scrollView.contentSize = size
        }
    }
    
    // MARK: - Properpties[Private]
    
    private lazy var scrollView: UIScrollView = UIScrollView()
    private lazy var imageView: UIImageView = UIImageView()
    
    // MARK: - View Cycle Life
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        setupSubviews()
        addGestureRecognizer()
    }
    
    private func setupSubviews() {
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        
        imageView.frame = scrollView.bounds
        scrollView.addSubview(imageView)
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 2
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.black
        
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = UIColor.black
        
    }
    
    private func addGestureRecognizer() {
        let oneTapGesture = UITapGestureRecognizer(target: self, action: #selector(PhotoViewerViewController.close))
        view.addGestureRecognizer(oneTapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(PhotoViewerViewController.zoom(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
        
        oneTapGesture.require(toFail: doubleTapGesture)
    }
    
    // MARK: - Selector
    @objc
    private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func zoom(_ tapGesture: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            let touchPoint = tapGesture.location(in: view)
            let zoomRect = CGRect(x: touchPoint.x - 40, y: touchPoint.y - 40, width: 80, height: 80)
            scrollView.zoom(to: zoomRect, animated: true)
        } else {
            scrollView.setZoomScale(1.0, animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension PhotoViewerViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.bounds.width - imageView.frame.width) * 0.5
        let offsetY = (scrollView.bounds.height - imageView.frame.height) * 0.5
        scrollView.contentInset = UIEdgeInsets(top: (offsetY < 0 ? 0 : offsetY), left: (offsetX < 0 ? 0 : offsetX), bottom: 0, right: 0)
    }
}

// MARK: - PhotoViewerDismissDelegate

extension PhotoViewerViewController: PhotoViewerDismissDelegate {
    
    func imageViewForPresent() -> UIImageView {
        let presentView = UIImageView()
        presentView.contentMode = .scaleAspectFill
        presentView.clipsToBounds = true
        presentView.image = imageView.image
        presentView.frame = scrollView.convert(imageView.frame, to: UIApplication.shared.keyWindow!)
        
        return imageView
    }
    
    func indexPathForDismiss() -> IndexPath {
        return indexPath
    }
}
