//
//  ChatViewModel.swift
//  WeChat
//
//  Created by 黄中山 on 2018/1/9.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import Foundation

final class ChatViewModel {

    // MARK: - Properties
    lazy var currentSender: SenderType = Sender(senderId: EMClient.shared().currentUsername, displayName: EMClient.shared().currentUsername)
    
    var userid: String = ""
    
    var messageList: [ChatMessage] = []
    
    var reloadCollectionViewClosure: ((_ noMoreData: Bool) -> Void)?
    var updateCollectionViewClosure: (([IndexPath], _ animated: Bool) -> Void)?
    
    // MARK: - Initializer
    
    init(userid: String) {
        self.userid = userid
        addObserver()
    }
    
    deinit {
        removeObserver()
    }
    
    func loadData() {
        debugPrint("本地历史消息加载---开始")
        MessageClient.shared.loadMessagesInConversation(userid, from: messageList.first?.messageId) { (result) in
            switch result {
            case .success(let messages):
                var res = [ChatMessage]()
                for message in messages {
                    switch message.body.type {
                    case EMMessageBodyTypeText:
                        let textMessage = ChatMessage(text: (message.body as! EMTextMessageBody).text,
                                                      sender: Sender(senderId: message.from, displayName: message.from),
                                                      messageId: message.messageId,
                                                      date: Date(timeIntervalSince1970: TimeInterval(message.timestamp/1000)))
                        res.append(textMessage)
                    case EMMessageBodyTypeImage:
                        let imageBody = message.body as! EMImageMessageBody
                        let size = imageBody.size.width == 0 ? CGSize(width: 60, height: 60) : imageBody.size
                        var imageMessage: ChatMessage
                        if !imageBody.thumbnailLocalPath.isEmpty, FileManager.default.fileExists(atPath: imageBody.thumbnailLocalPath) {
                            imageMessage = ChatMessage(thumbnailURL: imageBody.thumbnailLocalPath,
                                                       sourceURL: nil,
                                                       size: size,
                                                       isLocal: true,
                                                       sender: Sender(senderId: message.from, displayName: message.from),
                                                       messageId: message.messageId,
                                                       date: Date(timeIntervalSince1970: TimeInterval(message.timestamp/1000)))
                        } else {
                            imageMessage = ChatMessage(thumbnailURL: imageBody.thumbnailRemotePath,
                                                       sourceURL: nil,
                                                       size: size,
                                                       isLocal: false,
                                                       sender: Sender(senderId: message.from, displayName: message.from),
                                                       messageId: message.messageId,
                                                       date: Date(timeIntervalSince1970: TimeInterval(message.timestamp/1000)))
                        }
                        res.append(imageMessage)
                    default:
                        debugPrint("Not implement")
                    }
                    
                }
                if res.isEmpty {
                    self.reloadCollectionViewClosure?(true)
                } else {
                    res.append(contentsOf: self.messageList)
                    self.messageList = res
                    self.reloadCollectionViewClosure?(false)
                }
                
                debugPrint("本地历史消息加载---完成")
            case .failure:
                SVProgressHUD.showError(withStatus: "本地历史消息加载失败")
            }
        }
        
    }
    
//    func loadData() {
//        debugPrint("本地历史消息加载---开始")
//        MessageClient.shared.loadMessagesInConversation(userid, from: messageList.first?.messageId) { (result) in
//            switch result {
//            case .success(let messages):
//                var indices = [IndexPath]()
//
//                for message in messages {
//                    switch message.body.type {
//                    case EMMessageBodyTypeText:
//                        let textMessage = ChatMessage(text: (message.body as! EMTextMessageBody).text,
//                                                      sender: Sender(senderId: message.from, displayName: message.from),
//                                                      messageId: message.messageId,
//                                                      date: Date(timeIntervalSince1970: TimeInterval(message.timestamp/1000)))
//
//                        let indexPath = IndexPath(item: self.messageList.count, section: 0)
//                        self.messageList.append(textMessage)
//                        indices.append(indexPath)
//                    case EMMessageBodyTypeImage:
//                        let imageBody = message.body as! EMImageMessageBody
//                        let size = imageBody.size.width == 0 ? CGSize(width: 60, height: 60) : imageBody.size
//                        var imageMessage: ChatMessage
//                        if !imageBody.thumbnailLocalPath.isEmpty, FileManager.default.fileExists(atPath: imageBody.thumbnailLocalPath) {
//                            imageMessage = ChatMessage(thumbnailURL: imageBody.thumbnailLocalPath,
//                                                       sourceURL: nil,
//                                                       size: size,
//                                                       isLocal: true,
//                                                       sender: Sender(senderId: message.from, displayName: message.from),
//                                                       messageId: message.messageId,
//                                                       date: Date(timeIntervalSince1970: TimeInterval(message.timestamp/1000)))
//                        } else {
//                            imageMessage = ChatMessage(thumbnailURL: imageBody.thumbnailRemotePath,
//                                                       sourceURL: nil,
//                                                       size: size,
//                                                       isLocal: false,
//                                                       sender: Sender(senderId: message.from, displayName: message.from),
//                                                       messageId: message.messageId,
//                                                       date: Date(timeIntervalSince1970: TimeInterval(message.timestamp/1000)))
//                        }
//
//                        let indexPath = IndexPath(item: self.messageList.count, section: 0)
//                        self.messageList.append(imageMessage)
//                        indices.append(indexPath)
//                    default:
//                        debugPrint("Not implement")
//                    }
//
//                }
//                self.reloadCollectionViewClosure?(indices, false)
//                debugPrint("本地历史消息加载---完成")
//            case .failure:
//                SVProgressHUD.showError(withStatus: "本地历史消息加载失败")
//            }
//        }
//
//    }
    
    func markAllMessagesAsRead(conversationID: String) {
        MessageClient.shared.markAllMessagesAsRead(conversationID: conversationID)
    }
    
    // MARK: - Oberver
    private func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceivedMessages(_:)),
                                               name: Constant.WeChatDidReceivedMessagesName,
                                               object: userid)
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    private func didReceivedMessages(_ notification: Notification) {
        guard let message = notification.userInfo?["message"] as? EMMessage else {
            debugPrint("消息解析错误")
            return
        }
        
        // 将消息转化为消息模型并显示
        switch message.body.type {
        case EMMessageBodyTypeText:
            let textMessage = ChatMessage(text: (message.body as! EMTextMessageBody).text,
                                          sender: Sender(senderId: message.from, displayName: message.from),
                                          messageId: message.messageId,
                                          date: Date(timeIntervalSince1970: TimeInterval(message.timestamp/1000)))
            
            let indexPath = IndexPath(item: self.messageList.count, section: 0)
            messageList.append(textMessage)
            updateCollectionViewClosure?([indexPath], true)
        case EMMessageBodyTypeImage:
            let imageBody = message.body as! EMImageMessageBody
            let size = imageBody.size.width == 0 ? CGSize(width: 60, height: 60) : imageBody.size
            let imageMessage = ChatMessage(thumbnailURL: imageBody.thumbnailRemotePath,
                                       sourceURL: nil,
                                       size: size,
                                       isLocal: false,
                                       sender: Sender(senderId: message.from, displayName: message.from),
                                       messageId: message.messageId,
                                       date: Date(timeIntervalSince1970: TimeInterval(message.timestamp/1000)))
            
            let indexPath = IndexPath(item: self.messageList.count, section: 0)
            messageList.append(imageMessage)
            updateCollectionViewClosure?([indexPath], true)
        default:
            debugPrint("Not implement")
        }
    }

}
