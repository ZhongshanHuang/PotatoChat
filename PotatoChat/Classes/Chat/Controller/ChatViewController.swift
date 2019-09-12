//
//  ChatViewController.swift
//  WeChat
//
//  Created by 黄中山 on 2018/1/9.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit
import MapKit
import Photos.PHAsset
import Kingfisher

class ChatViewController: MessagesViewController {

    // MARK: - Prperties
    
    var userid: String = ""
    
    private lazy var viewModel: ChatViewModel = ChatViewModel(userid: userid)
    private lazy var photoViewerAnimator: PhotoViewerAnimator = PhotoViewerAnimator()
    private lazy var moreKeyboard: MoreKeyboard = {
        let keyboard = MoreKeyboard.keyboard()
        keyboard.delegate = self
        return keyboard
    }()
    private lazy var emoticonKeyboard: EmoticonKeyboard = EmoticonKeyboard { [weak self] (model) in
        self?.messageInputBar.textView.insertEmoticon(em: model)
    }
    private lazy var refreshControl: UIRefreshControl = UIRefreshControl()
    private lazy var needScrollToBottomAfterLoadData: Bool = true
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupSubviews()
        setupDelegate()
        setupViewModel()
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 将此用户下的未读消息标记为已读
        viewModel.markAllMessagesAsRead(conversationID: userid)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper
    
    private func setupSubviews() {
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        messagesCollectionView.addSubview(refreshControl)
    }
    
    private func setupDelegate() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
    }
    
    private func setupViewModel() {
        viewModel.reloadCollectionViewClosure = { [weak self] (noMoreData) in
            guard let strongSelf = self else { return }
            if !noMoreData {
                strongSelf.messagesCollectionView.reloadData()
                if strongSelf.needScrollToBottomAfterLoadData {
                    strongSelf.needScrollToBottomAfterLoadData = false
                    strongSelf.messagesCollectionView.scrollToBottom()
                }
            }
            strongSelf.refreshControl.endRefreshing()
        }
        
        viewModel.updateCollectionViewClosure = { [weak self] (indices, animated) in
            guard let strongSelf = self else { return }
            strongSelf.messagesCollectionView.insertItems(at: indices)
            strongSelf.messagesCollectionView.scrollToBottom(animated: animated)
        }
    }
    
    // MARK: - Selector
    
    @objc
    private func loadData() {
        viewModel.loadData()
    }
    
    // MARK: - Autorate
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - StatusBarStyle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

}



// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return viewModel.currentSender
    }
    
    func numberOfSections(in messageCollectionView: MessagesCollectionView) -> Int {
        return 1
    }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return viewModel.messageList.count
    }
    
    /// message content
    func messageForItem(at indexpath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return viewModel.messageList[indexpath.item]
    }
    
    /// cell top
    func cellTopLabelAttributedText(for message: MessageType, at indexpath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                                  attributes: [.foregroundColor: UIColor.darkGray, .font: UIFont.systemFont(ofSize: 12)])
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        guard let dataSource = messagesCollectionView.messagesDataSource else { return 0 }
        let topHeight: CGFloat = 30
        // 第一条信息需要展示时间
        if indexPath.item == 0 { return topHeight }
        
        // 后一条与前一条相差n秒需要展示时间
        let previousIndexPath = IndexPath(item: indexPath.item - 1, section: 0)
        let previousMessage = dataSource.messageForItem(at: previousIndexPath, in: messagesCollectionView)
        let timeIntervalSinceLastMessage = message.sentDate.timeIntervalSince(previousMessage.sentDate)
        if timeIntervalSinceLastMessage >= messagesCollectionView.showsDateHeaderAfterTimeInterval {
            return topHeight
        }
        return 0
    }
}

// MARK: - MessageDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    
    /// 设置头像avatarView
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.initials = message.sender.displayName
    }
    
    /// 设置图片
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        switch message.kind {
        case let .photo(mediaItem):
            if mediaItem.thumbnailURL.absoluteString.hasPrefix("http") == true {
                imageView.kf.setImage(with: mediaItem.thumbnailURL)
            } else if mediaItem.thumbnailURL.absoluteString.hasPrefix("file") == true {
                let provider = LocalFileImageDataProvider(fileURL: mediaItem.thumbnailURL)
                imageView.kf.setImage(with: provider)
            }
        default:
            debugPrint("No Implement")
            break
        }
    }
    
    /// Location Messages
    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "tabbar_badge")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(0, 0, 0)
            view.alpha = 0.0
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
                view.alpha = 1.0
            }, completion: nil)
        }
    }
}

// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        debugPrint("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        debugPrint("Message tapped")
        guard let cell = cell as? MediaMessageCell else { return }
        let indexPath = messagesCollectionView.indexPath(for: cell)!
        let message = viewModel.messageList[indexPath.item]
        
        switch message.kind {
        case .photo(let mediaItem):
            let photoViewer = PhotoViewerViewController()
            photoViewer.imageUrl = mediaItem.thumbnailURL
            photoViewer.indexPath = indexPath
            photoViewer.transitioningDelegate = photoViewerAnimator
            photoViewer.modalPresentationStyle = .fullScreen
            photoViewerAnimator.setDelegateParams(presentDelegate: self, indexPath: indexPath, dismissDelegate: photoViewer)
            present(photoViewer, animated: true, completion: nil)
        default:
            debugPrint("No impletion")
            break
        }
    }
    
    func didTapBackground(in cell: MessageCollectionViewCell) {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
}

// MARK: - PhotoViewerPresentDelegate

extension ChatViewController: PhotoViewerPresentDelegate {
    
    // 对应的imageview
    func imageViewForPresent(indexPath: IndexPath) -> UIImageView {
        let presentView = UIImageView()
        presentView.contentMode = .scaleAspectFill
        presentView.clipsToBounds = true
        
        if let cell = messagesCollectionView.cellForItem(at: indexPath) as? MediaMessageCell {
            presentView.image = cell.imageView.image
        }
        return presentView
    }
    
    // 起始位置
    func photoViewerPresentFromRect(indexPath: IndexPath) -> CGRect {
        guard let cell = messagesCollectionView.cellForItem(at: indexPath) as? MediaMessageCell else { return .zero }
        
        return cell.convert(cell.messageContainerView.frame, to: UIApplication.shared.keyWindow!)
    }
    
    // 目标位置
    func photoViewerPresentToRect(indexPath: IndexPath) -> CGRect {
        guard let cell = messagesCollectionView.cellForItem(at: indexPath) as? MediaMessageCell, let imageSize = cell.imageView.image?.size else { return .zero }
        
        let screenSize = UIScreen.main.bounds
        let h = imageSize.height * screenSize.width / imageSize.width
        var y: CGFloat = 0
        if h < screenSize.height {
            y = (screenSize.height - h) / 2
        }
        
        return CGRect(x: 0, y: y, width: screenSize.width, height: h)
    }
}

// MARK: - MessageLabelDelegate


// MARK: - MessageInputBarDelegate [消息发送]

extension ChatViewController: MessageInputBarDelegate {

    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // 构造消息模型更新到聊天记录中
        let messageId = UUID().uuidString + "\(Date().timeIntervalSince1970)"
        let message = ChatMessage(text: text, sender: currentSender(), messageId: messageId, date: Date())
        let indexPath = IndexPath(item: viewModel.messageList.count, section: 0)
        viewModel.messageList.append(message)
        inputBar.reset()
        messagesCollectionView.insertItems(at: [indexPath])
        messagesCollectionView.scrollToBottom()

        // 构建消息
        let body = EMTextMessageBody(text: text)
        let emMessage = EMMessage(conversationID: userid,
                                  from: viewModel.currentSender.senderId,
                                  to: userid,
                                  body: body,
                                  ext: [:])!
        emMessage.chatType = EMChatTypeChat
        
        // 发送消息
        MessageClient.shared.send(emMessage) { (result) in
            switch result {
            case .success:
                debugPrint("信息发送成功")
            case .failure:
                debugPrint("信息发送失败")
            }
        }
    }
    
    // 切换键盘
    func messageInputBar(_ inputBar: MessageInputBar, didSelectedButton type: MessageInputBarButtonType) {
        switch type {
        case .textView:
            inputBar.textView.inputView = nil
        case .more:
            inputBar.textView.inputView = moreKeyboard
        case .emoticon:
            inputBar.textView.inputView = emoticonKeyboard
        default:
            debugPrint(type)
        }
        inputBar.textView.becomeFirstResponder()
        inputBar.textView.reloadInputViews()
    }
    
}


// MARK: - 访问相册
extension ChatViewController: MoreKeyboardDelegate {
    
    func moreKeyboard(_ view: MoreKeyboard, didSelectedButton type: MoreKeyboardButtonType) {
        switch type {
        case .album:
            // 相册控制器
            let photoPicker = ImagePickerController(delegate: self)
            photoPicker.modalPresentationStyle = .fullScreen
            present(photoPicker, animated: true, completion: nil)
        }
    }
}

// MARK: - 相册回调-发送图片
extension ChatViewController: ImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: ImagePickerController, didFinishPickingPhotos photos: Array<UIImage>, sourceAssets: Array<PHAsset>, isOriginal: Bool) {
        // 构建消息
        let image = photos[0]
        let data = image.jpegData(compressionQuality: 0.9)
        
        let body = EMImageMessageBody(data: data, thumbnailData: data)
        let emMessage = EMMessage(conversationID: userid,
                                  from: viewModel.currentSender.senderId,
                                  to: userid,
                                  body: body,
                                  ext: [:])!
        emMessage.chatType = EMChatTypeChat
        // 发送消息
        MessageClient.shared.send(emMessage) { (result) in
            switch result {
            case .success(let message):
                // 构造消息模型更新到聊天记录中
                let imageBody = message.body as! EMImageMessageBody
                let size = imageBody.size.width == 0 ? CGSize(width: 60, height: 60) : imageBody.size
                let imageMessage = ChatMessage(thumbnailURL: imageBody.thumbnailLocalPath,
                                               sourceURL: nil,
                                               size: size,
                                               isLocal: true,
                                               sender: Sender(senderId: message.from, displayName: message.from),
                                               messageId: message.messageId,
                                               date: Date(timeIntervalSince1970: TimeInterval(message.timestamp/1000)))

                let indexPath = IndexPath(item: self.viewModel.messageList.count, section: 0)
                self.viewModel.messageList.append(imageMessage)
                self.messagesCollectionView.insertItems(at: [indexPath])
                self.messagesCollectionView.scrollToBottom()
                debugPrint("信息发送成功")
            case .failure:
                debugPrint("信息发送失败")
            }
        }
    }
}

