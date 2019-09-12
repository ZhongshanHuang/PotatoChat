//
//  ChatViewController.swift
//  WeChat
//
//  Created by 黄中山 on 2017/11/21.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import UIKit

private let kChatListViewCellIdentifier = "ChatListViewCellIdentifier"

class ChatListViewController: BaseViewController {

    // MARK: - Properties
    let viewModel: ChatListViewModel = ChatListViewModel()
    
    private lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: ChatListViewFlowLayout())
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()
        registerReusableViews()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 加载本地消息，从聊天控制器出来的时候也需要刷新列表。
        viewModel.loadData()
        
        // 订阅消息
        viewModel.registerMessages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 取消订阅消息
        viewModel.resignMessages()
    }
    
    // MARK: - Helper
    
    private func setupSubviews() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.white
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        if #available(iOS 11, *) {
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            collectionView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor).isActive = true
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
    }
    
    private func registerReusableViews() {
        collectionView.register(UINib(nibName: "ChatListViewCell", bundle: nil),
                                forCellWithReuseIdentifier: kChatListViewCellIdentifier)
    }
    
    private func setupViewModel() {
        viewModel.reloadCollectionViewClosure = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData()
            let unreadCount = strongSelf.viewModel.dataList.reduce(0, { (result, conversation) -> Int in
                return result + conversation.unreadCounts
            })
            strongSelf.tabBarItem.badgeValue = (unreadCount > 0 ? "\(unreadCount)" : nil)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ChatListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kChatListViewCellIdentifier, for: indexPath) as! ChatListViewCell
        cell.configure(with: viewModel.dataList[indexPath.row])
        return cell
    }
}


// MARK: - UICollectionViewDelegate

extension ChatListViewController: UICollectionViewDelegate {
    
    /// 跳转到聊天界面
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let userid = viewModel.dataList[indexPath.row].userid
        if userid.isEmpty {
            SVProgressHUD.showError(withStatus: "数据异常！")
            debugPrint("跳转失败，没有userid")
            return
        }

        let vc = ChatViewController()
        vc.userid = userid
        navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - UICollectionViewFlowLayout

class ChatListViewFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        itemSize = CGSize(width: UIScreen.main.bounds.width, height: 60)
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .vertical
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



