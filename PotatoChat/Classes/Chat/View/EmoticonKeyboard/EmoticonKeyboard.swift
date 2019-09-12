//
//  EmoticonKeyboard.swift
//  Animation3.0
//
//  Created by 黄山哥 on 2017/5/28.
//  Copyright © 2017年 黄山哥. All rights reserved.
//

import UIKit

private let kEmoticonViewHeight: CGFloat = 216
private let kEmoticonToolbarHeight: CGFloat = 36

private let kEmoticonRow: CGFloat = 3
private let kEmoticonColumn: CGFloat = 7

private let kEmoticonCellIdentifier: String = "kEmoticonCellIdentifier"

class EmoticonKeyboard: UIView {

    private var selectEmoticonClosure: (EmoticonModel) -> Void

    private lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: EmoticonLayout())
    private lazy var toolbar: UIToolbar = UIToolbar()
    private lazy var sendButton: UIButton = UIButton(type: .system)
    
    private lazy var emoticonManager = EmoticonManager()
    private var packages: [EmoticonPackage] {
        return emoticonManager.packages
    }

    init(selectEmoticonClosure: @escaping (EmoticonModel) -> Void) {
        self.selectEmoticonClosure = selectEmoticonClosure
        var rect = UIScreen.main.bounds
        rect.size.height = kEmoticonViewHeight
        super.init(frame: rect)
        
        backgroundColor = UIColor.white
        prepareCollectionView()
        prepareToolbar()
        prepareSendButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func prepareCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmoticonCell.self, forCellWithReuseIdentifier: kEmoticonCellIdentifier)
        collectionView.backgroundColor = UIColor.white
        addSubview(collectionView)
    }

    private func prepareToolbar() {
        toolbar.tintColor = UIColor.darkGray
        toolbar.barTintColor = UIColor(white: 0.9, alpha: 1.0)
        addSubview(toolbar)
        
        var items = [UIBarButtonItem]()
        let count = packages.count
        for (index, p) in packages.enumerated() {
            let item = UIBarButtonItem(title: p.group_name_cn, style: .plain, target: self, action: #selector(clickToolBarItem(_:)))
            item.tag = index
            items.append(item)
            
            // 最后一个item不需要加入间隔
            if index == count - 1 { break }
            let fixedItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            fixedItem.width = 12
            items.append(fixedItem)
        }
        toolbar.items = items
    }
    
    private func prepareSendButton() {
        sendButton.setTitle("发送", for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        sendButton.setTitleColor(UIColor.black, for: .normal)
        addSubview(sendButton)
    }

    @objc
    private func clickToolBarItem(_ item: UIBarButtonItem) {
        collectionView.scrollToItem(at: IndexPath(item: 0, section: item.tag), at: .left, animated: true)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: kEmoticonViewHeight - kEmoticonToolbarHeight)
        
        toolbar.frame = CGRect(x: 0, y: kEmoticonViewHeight - kEmoticonToolbarHeight, width: UIScreen.main.bounds.width - kEmoticonToolbarHeight, height: kEmoticonToolbarHeight)
        
        sendButton.frame = CGRect(x: toolbar.frame.maxX, y: toolbar.frame.minY, width: kEmoticonToolbarHeight, height: kEmoticonToolbarHeight)
    }
}

// MARK: - UICollectionViewDataSource
extension EmoticonKeyboard: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return packages.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return packages[section].emoticons.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kEmoticonCellIdentifier, for: indexPath) as! EmoticonCell

        cell.emoticon = packages[indexPath.section].emoticons[indexPath.row]
        return cell
    }
}



// MARK: - UICollectionViewDelegate
extension EmoticonKeyboard: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let em = packages[indexPath.section].emoticons[indexPath.row]
        return !em.isEmpty
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let em = packages[indexPath.section].emoticons[indexPath.row]
        selectEmoticonClosure(em)
    }
}


// MARK: - 布局layout
private class EmoticonLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        
        let w = floor((collectionView!.bounds.width) / kEmoticonColumn)
        let margin = floor((collectionView!.bounds.height - kEmoticonRow * w) * 0.5)
        
        itemSize = CGSize(width: w, height: w)
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        sectionInset.top = margin
        sectionInset.bottom = margin
        
        scrollDirection = .horizontal
        
        collectionView?.isPagingEnabled = true
        collectionView?.bounces = false
        collectionView?.showsHorizontalScrollIndicator = false
    }
}


// MARK: - 表情cell
private class EmoticonCell: UICollectionViewCell {

    var emoticon: EmoticonModel? {
        didSet {
            // 删除按钮
            if emoticon?.isRemoved == true {
                emoticonButton.setImage(UIImage(named: "delete-emoji"), for: .normal)
            } else {
                emoticonButton.setTitle(emoticon?.emoticon, for: .normal)
                emoticonButton.setImage(UIImage(contentsOfFile: emoticon!.imagePath), for: .normal)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        emoticonButton.frame = bounds.insetBy(dx: 4, dy: 4)
        emoticonButton.isUserInteractionEnabled = false
        contentView.addSubview(emoticonButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var emoticonButton: UIButton = UIButton(type: .custom)
}
