//
//  ContactsViewModel.swift
//  WeChat
//
//  Created by 黄中山 on 2018/5/13.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import Foundation

final class ContactsViewModel {
    
    // MARK: - Properties
    var sortedKeys = [String]()
    var list = Dictionary<String, Array<String>>()
    var reloadCollectionViewClosure: (() -> Void)?
    var showFriendRequestTip: (() -> Void)?
    
    init() {
        addObserver()
    }
    
    deinit {
        removeObserver()
    }
    
    func loadData() {
        MessageClient.shared.loadContacts { (result) in
            switch result {
            case .success(let contacts):
                self.sortedKeys = []
                self.list = [:]
                // 新朋友
                self.sortedKeys.append("🔍")
                // 联系人列表
                for contact in contacts {
        
                    let firstChar = contact[contact.startIndex..<contact.index(after: contact.startIndex)].uppercased()
                    if var tmp = self.list[firstChar] {
                        tmp.append(contact)
                    } else {
                        var tmp = [String]()
                        tmp.append(contact)
                        self.list[firstChar] = tmp
                    }
                }
                let contactSortedKeys = self.list.keys.sorted(by: <)
                self.sortedKeys.append(contentsOf: contactSortedKeys)
                self.list["🔍"] = ["新朋友"]
                self.reloadCollectionViewClosure?()
            case .failure:
                SVProgressHUD.showError(withStatus: "获取聊天列表失败")
            }
        }
    }

    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveFriendRequest(_:)), name: Constant.WeChatDidReceiveFriendRequestName, object: nil)
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    private func receiveFriendRequest(_ notification: Notification) {
        showFriendRequestTip?()
    }
    
}
