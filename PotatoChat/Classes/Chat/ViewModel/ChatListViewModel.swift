//
//  ChatViewModel.swift
//  WeChat
//
//  Created by 黄中山 on 2018/1/7.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import Foundation

final class ChatListViewModel {
    
    // MARK: - Properties
    var dataList: [Conversation] = []
    
    /// binding
    var reloadCollectionViewClosure: (() -> Void)?
    
    /// dataAddSource
    let dataAddSource = DispatchSource.makeUserDataAddSource()
    
    init() {
        dataAddSource.setEventHandler {
            _ = self.dataAddSource.data
            MessageClient.shared.getAllConversations { (conversations) in
                self.dataList = conversations
                self.reloadCollectionViewClosure?()
            }
        }
        dataAddSource.resume()
    }
    
    // MARK: - Initializer
    deinit {
        resignMessages()
    }
    
    
    // MARK: - Methods [public]
    
    /// 订阅消息
    func registerMessages() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateData(_:)),
                                               name: Constant.WeChatDidReceivedMessagesName,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loadData),
                                               name: Constant.WeChatConversationListDidUpdateName,
                                               object: nil)
    }
    
    /// 取消订阅消息
    func resignMessages() {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 加载会话数据-async
    @objc
    func loadData() {
        dataAddSource.add(data: 1)
    }
    
    // MARK: - Methods [private]
    @objc
    private func updateData(_ notification: Notification) {

        guard let message = notification.userInfo?["message"] as? EMMessage else { return }
        
        let index = dataList.firstIndex { (conversation) -> Bool in
            conversation.userid == message.conversationId
        }
        
        if let index = index {
            var messageContent: String = ""
            switch message.body.type {
            case EMMessageBodyTypeText:
                messageContent = (message.body as! EMTextMessageBody).text
            case EMMessageBodyTypeImage:
                messageContent = "[图片]"
            default:
                messageContent = "$_$未实现的类型$_$"
            }
            
            dataList[index].messageDate = Double(message.timestamp/1000)
            dataList[index].messageContent = messageContent
            dataList[index].unreadCounts += 1
            
            dataList.sort { (conver1, conver2) -> Bool in
                conver1.messageDate > conver2.messageDate
            }
            reloadCollectionViewClosure?()
        }
    }
    
}
