//
//  PhotoPickerViewController.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2018/3/19.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit
import Photos.PHAsset

private let kAssetCellIdentifier: String = "AssetCellIdentifier"

class PhotoPickerViewController: UIViewController {

    // MARK: - Properties[public]
    var columnCount: Int = 4
    var albumModel: AlbumModel?
    var shouldScrollToBottom: Bool = true
    
    private var isFirstDisplay: Bool = true
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupConstraints()
        fetchAssetModels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstDisplay {
            isFirstDisplay = false
        } else {
            collectionView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper Methods
    
    private func setupSubviews() {
        view.backgroundColor = UIColor.white
        title = "照片"
        
        // right bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(rightBarButtonClick))
        
        // left bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(leftBarButtonClick))

//        if #available(iOS 11, *) {
//            collectionView.contentInsetAdjustmentBehavior = .never
//        } else {
//            automaticallyAdjustsScrollViewInsets = false
//        }
        
        // flowLayout
        let margin: CGFloat = imagePicker.margin
        let width: CGFloat = (view.bounds.width  - 2 * margin - CGFloat(columnCount - 1) * margin) / CGFloat(columnCount)
        flowLayout.itemSize = CGSize(width: width, height: width)
        flowLayout.minimumLineSpacing = margin
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        
        // collectionView
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.white
        view.addSubview(collectionView)
        
        // proxy
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register cell
        collectionView.register(AssetCell.self, forCellWithReuseIdentifier: kAssetCellIdentifier)
        
        // bottomBar
        view.addSubview(bottomBar)
        bottomBar.addSubview(previewBtn)
        bottomBar.addSubview(originalBtn)
        bottomBar.addSubview(senderBtn)
    }
    
    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11, *) {
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        } else {
            collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        }
        
        // bottomBar
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        var height: CGFloat = 44
        if #available(iOS 11.0, *) {
            height = UIApplication.shared.windows[0].safeAreaInsets.bottom + 44
            bottomBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
            bottomBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        } else {
            bottomBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            bottomBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        }
        bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomBar.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        // previewBtn
        previewBtn.translatesAutoresizingMaskIntoConstraints = false
        previewBtn.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 7).isActive = true
        previewBtn.leftAnchor.constraint(equalTo: bottomBar.leftAnchor).isActive = true
        previewBtn.widthAnchor.constraint(equalToConstant: 60).isActive = true
        previewBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        // originalBtn
        originalBtn.translatesAutoresizingMaskIntoConstraints = false
        originalBtn.topAnchor.constraint(equalTo: previewBtn.topAnchor).isActive = true
        originalBtn.centerXAnchor.constraint(equalTo: bottomBar.centerXAnchor).isActive = true
        originalBtn.widthAnchor.constraint(equalToConstant: 60).isActive = true
        originalBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        // senderBtn
        senderBtn.translatesAutoresizingMaskIntoConstraints = false
        senderBtn.topAnchor.constraint(equalTo: previewBtn.topAnchor).isActive = true
        senderBtn.rightAnchor.constraint(equalTo: bottomBar.rightAnchor, constant: -10).isActive = true
        senderBtn.widthAnchor.constraint(equalToConstant: 60).isActive = true
        senderBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    private func fetchAssetModels() {
        
        // 有数据的话直接显示
        if albumModel != nil {
            updateCollectionView()
            return
        }
        
        // 没有传递数据过来，自己加载相机相册
        DispatchQueue.global(qos: .userInitiated).async {
            PhotoPickerManager.shared.loadCameraRollAlbum(allowPickingVideo: self.imagePicker.allowPickingVideo, needFetchAssets: true, completion: { (model) in
                self.albumModel = model
                self.updateCollectionView()
            })
        }
    }
    
    /// CollectionView reloadData
    private func updateCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            if self.shouldScrollToBottom {
                self.collectionView.scrollToItem(at: IndexPath(item: self.collectionView.numberOfItems(inSection: 0) - 1, section: 0),
                                            at: .top,
                                            animated: false)
            }
            
        }
        
    }
    
    // MARK: - Selector
    
    // 返回点击
    @objc private func leftBarButtonClick() {
        navigationController?.popViewController(animated: true)
    }
    
    // 取消点击
    @objc private func rightBarButtonClick() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // 预览点击
    @objc private func previewBtnClick(_ sender: UIButton) {
        let vc = PhotoPreviewViewController()
        vc.assetModels = Array(imagePicker.selectedModels)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // 原图选项
    @objc private func originalBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    // 发送按钮
    @objc private func senderBtnClick(_ sender: UIButton) {
        let isOriginal = originalBtn.isSelected
        
        var selectImages: [UIImage] = []
        var selectAssets: [PHAsset] = []
        
        
        for model in self.imagePicker.selectedModels {
            selectAssets.append(model.asset)

            self.group.enter()
            // 线程同步
            _ = self.semaphore.wait(wallTimeout: DispatchWallTime.distantFuture)
            PhotoPickerManager.shared.loadPhoto(with: model.asset, isOriginal: isOriginal, completion: { (image, _, isDegraded) in
                if !isDegraded, let image = image {
                    selectImages.append(image)
                    self.semaphore.signal()
                    self.group.leave()
                }
            })
        }
        
        // 照片获取完成后
        group.notify(queue: DispatchQueue.main) {
            // 回调代理方法
            self.imagePicker.pickerDelegate?.imagePickerController?(self.imagePicker, didFinishPickingPhotos: selectImages, sourceAssets: selectAssets, isOriginal: isOriginal)
            // 退出
            self.imagePicker.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    // MARK: - Properties[private-lazy]
    private lazy var bottomBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 34/255.0, green: 34/255.0, blue: 34/255.0, alpha: 1.0)
        return view
    }()
    
    private lazy var previewBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(previewBtnClick(_:)), for: .touchUpInside)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        btn.setTitle("预览", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.lightGray, for: .disabled)
        btn.isEnabled = false
        return btn
    }()
    
    private lazy var originalBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(originalBtnClick(_:)), for: .touchUpInside)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitle("原图", for: .normal)
        btn.setImage(UIImage(named: "photo_original_def"), for: .normal)
        btn.setImage(UIImage(named: "photo_original_sel"), for: .selected)
        btn.setTitleColor(UIColor.white, for: .normal)
        return btn
    }()
    
    private lazy var senderBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(senderBtnClick(_:)), for: .touchUpInside)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.setTitle("发送", for: .normal)
        btn.backgroundColor = UIColor.green
        btn.alpha = 0.5
        btn.layer.cornerRadius = 5
        btn.isEnabled = false
        return btn
    }()
    
    private lazy var flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    private lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    
    private lazy var group: DispatchGroup = DispatchGroup()
    private lazy var semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    private var imagePicker: ImagePickerController {
        return navigationController as! ImagePickerController
    }

}

// MARK: - UICollectionViewDataSource

extension PhotoPickerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumModel?.models.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kAssetCellIdentifier, for: indexPath) as! AssetCell
        
        cell.setAssetModel(albumModel!.models[indexPath.row])
        cell.selectBlockHander = {[weak self] selectCount in
            let isEnabled = (selectCount > 0)
            self?.previewBtn.isEnabled = isEnabled
            self?.senderBtn.isEnabled = isEnabled
            self?.senderBtn.alpha = (isEnabled ? 1.0 : 0.5)
        }
        return cell
    }
}


// MARK: - UICollectionViewDelegate

extension PhotoPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PhotoPreviewViewController()
        vc.assetModels = albumModel!.models
        vc.targetIndexPath = indexPath
        navigationController?.pushViewController(vc, animated: true)
    }
}
