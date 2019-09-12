//
//  MessageClient.swift
//  WeChat
//
//  Created by 黄中山 on 2018/1/21.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import Foundation


class MessageClient: NSObject {
    
    static let shared: MessageClient = MessageClient()
    
    private override init() {
        // 禁止自动下载缩略图，后续展示时交给Kingfisher下载
        EMClient.shared().options.isAutoDownloadThumbnail = false
    }
}

// MARK: - 订阅服务器消息
extension MessageClient {
    
    /// 订阅服务器消息
    func registerMessages() {
        // 消息代理
        EMClient.shared().chatManager.add(self, delegateQueue: nil)
        // 好友申请
        EMClient.shared().contactManager.add(self, delegateQueue: nil)
    }
    
    /// 取消订阅服务器消息
    func resignMessages() {
        EMClient.shared().chatManager.remove(self)
    }
}

// MARK: - 发送消息
extension MessageClient {
    /// 发送消息
    func send(_ message: EMMessage, completion: @escaping CompletionHandler) {
        EMClient.shared().chatManager.send(message, progress: nil) { (aMessage, error) in
            if let error = error {
                completion(Result.failure(error))
            } else {
                completion(Result.success(aMessage!))
            }
        }
    }
}

// MARK: - 注册接收消息回调
extension MessageClient: EMChatManagerDelegate {
    
    func conversationListDidUpdate(_ aConversationList: [Any]!) {
        NotificationCenter.default.post(name: Constant.WeChatConversationListDidUpdateName, object: nil)
    }
    
    func messagesDidReceive(_ aMessages: [Any]!) {
        guard let messages = aMessages as? [EMMessage] else { return }
        
        // 通知对应的id的订阅者有新消息到了
        for message in messages {
            NotificationCenter.default.post(name: Constant.WeChatDidReceivedMessagesName, object: message.conversationId, userInfo: ["message": message])
            dbInsert(message)
        }
    }

}

// MARK: - 注册添加好友回调

private let friendRequestKey = "friendRequestKey"

extension MessageClient: EMContactManagerDelegate {
    
    // 收到好友申请
    func friendRequestDidReceive(fromUser aUsername: String!, message aMessage: String!) {
        // 暂时存储在UserDefaults，应该存在sqlite数据库
        if var requests = UserDefaults.standard.array(forKey: friendRequestKey) as? [String] {
            requests.append(aUsername)
            UserDefaults.standard.set(requests, forKey: friendRequestKey)
        } else {
            var requests = [String]()
            requests.append(aUsername)
            UserDefaults.standard.set(requests, forKey: friendRequestKey)
        }
        NotificationCenter.default.post(name: Constant.WeChatDidReceiveFriendRequestName, object: nil, userInfo: ["userName": aUsername ?? "", "message": aMessage ?? ""])
    }
    
    // 发送的好友申请被通过
    func friendRequestDidApprove(byUser aUsername: String!) {
        
    }
    
    // 发送的好友申请被拒绝
    func friendRequestDidDecline(byUser aUsername: String!) {
        
    }
}

// MARK: - 更改本地数据

extension MessageClient {
    
    // 插入单条消息
    func dbInsert(_ message: EMMessage) {
        let conversationID = message.conversationId
        let conversation = EMClient.shared().chatManager.getConversation(conversationID, type: EMConversationTypeChat, createIfNotExist: true)
        conversation?.insert(message, error: nil)
    }
    
    // update 单条消息
    func dbUpdate(_ message: EMMessage) {
        EMClient.shared().chatManager.update(message, completion: nil)
    }
}


// MARK: - 加载本地消息数据
extension MessageClient {
    
    /// 将消息设置为已读
    func markMessageAsRead(conversationID: String, messageId: String) {
        let conversation = EMClient.shared().chatManager.getConversation(conversationID, type: EMConversationTypeChat, createIfNotExist: false)
        conversation?.markMessageAsRead(withId: messageId, error: nil)
    }
    
    /// 将指定conversationID下所有未读消息设置为已读
    func markAllMessagesAsRead(conversationID: String) {
        let conversation = EMClient.shared().chatManager.getConversation(conversationID, type: EMConversationTypeChat, createIfNotExist: false)
        conversation?.markAllMessages(asRead: nil)
    }
    
    // 获取conversation列表
    func getAllConversations(completionHandler: @escaping ([Conversation]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let conversationList = EMClient.shared().chatManager.getAllConversations() as? [EMConversation] else {
                DispatchQueue.main.async {
                    completionHandler([])
                }
                return
            }
            var results = [Conversation]()
            for conversation in conversationList {
                var messageDate: Double = Date().timeIntervalSince1970
                var messageContent: String = ""
                if let lastMessage = conversation.latestMessage {
                    messageDate = Double(lastMessage.timestamp/1000)
                    switch conversation.latestMessage.body.type {
                    case EMMessageBodyTypeText:
                        messageContent = (lastMessage.body as! EMTextMessageBody).text
                    case EMMessageBodyTypeImage:
                        messageContent = "[图片]"
                    default:
                        messageContent = "$_$未实现的类型$_$"
                    }
                }
                
                let model = Conversation(userid: conversation.conversationId,
                                         unreadCounts: Int(conversation.unreadMessagesCount),
                                         messageDate: messageDate,
                                         messageType: 0,
                                         messageContent: messageContent)
                results.append(model)
            }
            DispatchQueue.main.async {
                completionHandler(results)
            }
        }
        
    }
    
    /// 根据conversationID获取会话
    @discardableResult
    func getConversation(by id: String) -> EMConversation {
        let conversation = EMClient.shared().chatManager.getConversation(id, type: EMConversationTypeChat, createIfNotExist: true)
        return conversation!
    }
    
    /// 根据conversationID获取消息
    func loadMessagesInConversation(_ conversationID: String, from messageId: String? = nil, count: Int = 30, completion: @escaping (Result<[EMMessage]>) -> Void) {
        let conversation = EMClient.shared().chatManager.getConversation(conversationID, type: EMConversationTypeChat, createIfNotExist: false)
        
        conversation?.loadMessagesStart(fromId: messageId,
                                        count: Int32(count),
                                        searchDirection: EMMessageSearchDirectionUp,
                                        completion: { (messages, error) in
            if error == nil, let messages = messages as? [EMMessage] {
                completion(Result.success(messages))
            } else {
                completion(Result.failure(error!))
            }
        })
    }
}

// MARK: - 通讯录相关

extension MessageClient {
    
    /// 获取好友列表
    func loadContacts(_ completion: @escaping (Result<[String]>) -> Void) {
        // 先从本地获取
        if let locals = EMClient.shared().contactManager.getContacts() as? [String], !locals.isEmpty {
            completion(Result.success(locals))
            return
        }
        
        // 本地没有，则从服务器获取
        EMClient.shared().contactManager.getContactsFromServer(completion: { (results, error) in
            if error == nil, let results = results as? [String] {
                completion(Result.success(results))
            } else {
                completion(Result.failure(error!))
            }
        })
    }
    
    /// 添加好友
    func addContact(_ username: String, with message: String, completionHandler: ((Result<String>) -> Void)?) {
        EMClient.shared().contactManager.addContact(username, message: message) { (userName, error) in
            if let error = error {
                completionHandler?(Result.failure(error))
            } else {
                completionHandler?(Result.success(userName!))
            }
        }
    }
    
    /// 删除好友
    func deleteContact(_ username: String, isDeleteConversation: Bool, completionHandler: ((Result<String>) -> Void)?) {
        EMClient.shared().contactManager.deleteContact(username, isDeleteConversation: isDeleteConversation) { (userName, error) in
            if let error = error {
                completionHandler?(Result.failure(error))
            } else {
                completionHandler?(Result.success(userName!))
            }
        }
    }
    
    /// 同意添加好友
    func approveFriendRequest(frome username: String, completionHandler: ((Result<String>) -> Void)?) {
        EMClient.shared().contactManager.approveFriendRequest(fromUser: username) { (userName, error) in
            if let error = error {
                completionHandler?(Result.failure(error))
            } else {
                completionHandler?(Result.success(userName!))
            }
        }
    }
    
    /// 拒绝添加好友
    func declineFriendRequest(from username: String, completionHandler: ((Result<String>) -> Void)?) {
        EMClient.shared().contactManager.declineFriendRequest(fromUser: username) { (userName, error) in
            if let error = error {
                completionHandler?(Result.failure(error))
            } else {
                completionHandler?(Result.success(userName!))
            }
        }
    }
    
    /// 获取好友申请列表
    func loadFriendRequests() -> [String] {
        if let requests = UserDefaults.standard.array(forKey: friendRequestKey) as? [String] {
            return requests
        }
        return []
    }
    
    /// 删除好友申请列表中的某个申请
    func deleteFriendRequest(_ username: String) {
        if var requests = UserDefaults.standard.array(forKey: friendRequestKey) as? [String], let index = requests.firstIndex(of: username) {
            requests.remove(at: index)
            UserDefaults.standard.set(requests, forKey: friendRequestKey)
        }
    }
}

enum Result<Value> {
    case success(Value)
    case failure(EMError)
    
    /// Returns `true` if the result is a success, `false` otherwise.
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    /// Returns `true` if the result is a failure, `false` otherwise.
    public var isFailure: Bool {
        return !isSuccess
    }
    
    /// Returns the associated value if the result is a success, `nil` otherwise.
    public var value: Value? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    public var error: EMError? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

typealias CompletionHandler = (Result<EMMessage>) -> Void

