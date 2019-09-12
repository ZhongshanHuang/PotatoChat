//
//  MessagesViewController.swift
//  MessageExample
//
//  Created by 黄中山 on 2017/11/26.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import UIKit

class MessagesViewController: UIViewController {

    // MARK: - Properties [public]
    
    lazy var messagesCollectionView: MessagesCollectionView = MessagesCollectionView()
    lazy var messageInputBar: MessageInputBar = MessageInputBar()
    
    var scrollsToBottomOnKeybordBeginsEditing: Bool = true
    var maintainPositionOnKeyboardFrameChanged: Bool = true
    
    // MARK: - Properties [override]
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    // MARK: - Properties [private]
    
    private var isFirstLayout: Bool = true
    var isMessagesControllerBeingDismissed: Bool = false
    var selectedIndexPathForMenu: IndexPath?
    
    var additionalBottomInset: CGFloat = 0 {
        didSet {
            let delta = additionalBottomInset - oldValue
            messageCollectionViewBottomInset += delta
        }
    }
    
    var isTypingIndicatorHidden: Bool {
        return messagesCollectionView.isTypingIndicatorHidden
    }
    
    var messageCollectionViewBottomInset: CGFloat = 0 {
        didSet {
            messagesCollectionView.contentInset.bottom = messageCollectionViewBottomInset
            messagesCollectionView.scrollIndicatorInsets.bottom = messageCollectionViewBottomInset
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupDefaults()
        setupSubviews()
        setupConstraints()
        setupDelegates()
        addMenuControllerObservers()
        addObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isMessagesControllerBeingDismissed = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isMessagesControllerBeingDismissed = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isMessagesControllerBeingDismissed = false
    }
    
    override func viewDidLayoutSubviews() {
        if isFirstLayout {
            defer { isFirstLayout = false }
            addKeyboardObservers()
            messageCollectionViewBottomInset = requiredInitialScrollViewBottomInset()
        }
        adjustScrollViewTopInset()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
        }
        messageCollectionViewBottomInset = requiredInitialScrollViewBottomInset()
    }
    
    deinit {
        removeKeyboardObservers()
        removeMenuControllerObservers()
        removeObservers()
        clearMemoryCache()
    }
    
    // MARK: - Typing Indicator API
    
    /// Sets the typing indicator sate by inserting/deleting the `TypingBubbleCell`
    ///
    /// - Parameters:
    ///   - isHidden: A Boolean value that is to be the new state of the typing indicator
    ///   - animated: A Boolean value determining if the insertion is to be animated
    ///   - updates: A block of code that will be executed during `performBatchUpdates`
    ///              when `animated` is `TRUE` or before the `completion` block executes
    ///              when `animated` is `FALSE`
    ///   - completion: A completion block to execute after the insertion/deletion
    open func setTypingIndicatorViewHidden(_ isHidden: Bool, animated: Bool, whilePerforming updates: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        
        guard isTypingIndicatorHidden != isHidden else {
            completion?(false)
            return
        }
        
        let section = messagesCollectionView.numberOfSections
        messagesCollectionView.setTypingIndicatorViewHidden(isHidden)
        
        if animated {
            messagesCollectionView.performBatchUpdates({ [weak self] in
                self?.performUpdatesForTypingIndicatorVisability(at: section)
                updates?()
                }, completion: completion)
        } else {
            performUpdatesForTypingIndicatorVisability(at: section)
            updates?()
            completion?(true)
        }
    }
    
    /// Performs a delete or insert on the `MessagesCollectionView` on the provided section
    ///
    /// - Parameter section: The index to modify
    private func performUpdatesForTypingIndicatorVisability(at section: Int) {
        if isTypingIndicatorHidden {
            messagesCollectionView.deleteSections([section - 1])
        } else {
            messagesCollectionView.insertSections([section])
        }
    }
    
    /// A method that by default checks if the section is the last in the
    /// `messagesCollectionView` and that `isTypingIndicatorViewHidden`
    /// is FALSE
    ///
    /// - Parameter section
    /// - Returns: A Boolean indicating if the TypingIndicator should be presented at the given section
    public func isSectionReservedForTypingIndicator(_ section: Int) -> Bool {
        return !messagesCollectionView.isTypingIndicatorHidden && section == self.numberOfSections(in: messagesCollectionView) - 1
    }
    
    // MARK: - Methods [private]
    
    private func setupDefaults() {
        view.backgroundColor = .white
        extendedLayoutIncludesOpaqueBars = true
        
        if #available(iOS 11.0, *) {
            messagesCollectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        messagesCollectionView.alwaysBounceVertical = true
    }
    
    private func setupDelegates() {
        messagesCollectionView.delegate = self
        messagesCollectionView.dataSource = self
    }
    
    private func setupSubviews() {
        view.addSubview(messagesCollectionView)
        view.addSubview(messageInputBar)
    }
    
    var messageInputBarBottomConstraint: NSLayoutConstraint?
    
    private func setupConstraints() {
        messagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let top: NSLayoutConstraint = messagesCollectionView.topAnchor.constraint(equalTo: view.topAnchor)
        let bottom: NSLayoutConstraint = messagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let leading: NSLayoutConstraint = messagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailing: NSLayoutConstraint = messagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        NSLayoutConstraint.activate([top, leading, bottom, trailing])
        
        // messageInputbar (高度自动计算，宽度需要设置)
        messageInputBar.translatesAutoresizingMaskIntoConstraints = false
        
        messageInputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        messageInputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        messageInputBarBottomConstraint = messageInputBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        messageInputBarBottomConstraint?.isActive = true
        
        adjustScrollViewTopInset()
    }
}


// MARK: - UICollectionViewDataSource

extension MessagesViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let collectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }
        let sections = collectionView.messagesDataSource?.numberOfSections(in: collectionView) ?? 0
        return collectionView.isTypingIndicatorHidden ? sections : sections + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let collectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }
        if isSectionReservedForTypingIndicator(section) {
            return 1
        }
        return collectionView.messagesDataSource?.numberOfItems(inSection: section, in: collectionView) ?? 0
    }

    /// Notes:
    /// - If you override this method, remember to call MessagesDataSource's customCell(for:at:in:)
    /// for MessageKind.custom messages, if necessary.
    ///
    /// - If you are using the typing indicator you will need to ensure that the section is not
    /// reserved for it with `isSectionReservedForTypingIndicator` defined in
    /// `MessagesCollectionViewFlowLayout`
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }
        
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }
        
        if isSectionReservedForTypingIndicator(indexPath.section) {
            return messagesDataSource.typingIndicator(at: indexPath, in: messagesCollectionView)
        }
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        switch message.kind {
        case .text, .attributedText, .emoji:
            let cell = messagesCollectionView.dequeueReusableCell(TextMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .photo, .video:
            let cell = messagesCollectionView.dequeueReusableCell(MediaMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .location:
            let cell = messagesCollectionView.dequeueReusableCell(LocationMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .audio:
            let cell = messagesCollectionView.dequeueReusableCell(AudioMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .contact:
            let cell = messagesCollectionView.dequeueReusableCell(ContactMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .custom:
            return messagesDataSource.customCell(for: message, at: indexPath, in: messagesCollectionView)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }
        
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return displayDelegate.messageHeaderView(for: indexPath, in: messagesCollectionView)
        case UICollectionView.elementKindSectionFooter:
            return displayDelegate.messageFooterView(for: indexPath, in: messagesCollectionView)
        default:
            fatalError(MessageKitError.unrecognizedSectionKind)
        }
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension MessagesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let messagesFlowLayout = collectionViewLayout as? MessagesCollectionViewFlowLayout else { return .zero }
        return messagesFlowLayout.sizeForItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }
        guard let messagesLayoutDelegate = messagesCollectionView.messagesLayoutDelegate else {
            fatalError(MessageKitError.nilMessagesLayoutDelegate)
        }
        if isSectionReservedForTypingIndicator(section) {
            return .zero
        }
        return messagesLayoutDelegate.headerViewSize(for: section, in: messagesCollectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? TypingIndicatorCell else { return }
        cell.typingBubble.startAnimating()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }
        guard let messagesLayoutDelegate = messagesCollectionView.messagesLayoutDelegate else {
            fatalError(MessageKitError.nilMessagesLayoutDelegate)
        }
        if isSectionReservedForTypingIndicator(section) {
            return .zero
        }
        return messagesLayoutDelegate.footerViewSize(for: section, in: messagesCollectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else { return false }
        
        if isSectionReservedForTypingIndicator(indexPath.section) {
            return false
        }
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        switch message.kind {
        case .text, .attributedText, .emoji, .photo:
            selectedIndexPathForMenu = indexPath
            return true
        default:
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if isSectionReservedForTypingIndicator(indexPath.section) {
            return false
        }
        return (action == NSSelectorFromString("copy:"))
    }
    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }
        let pasteBoard = UIPasteboard.general
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        switch message.kind {
        case .text(let text), .emoji(let text):
            pasteBoard.string = text
        case .attributedText(let attributedText):
            pasteBoard.string = attributedText.string
//        case .photo(let mediaItem):
//            pasteBoard.image = mediaItem.image ?? mediaItem.placeholderImage
        default:
            break
        }
    }
    
    // 手指滑动的时候缩回键盘
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        messageInputBar.textView.resignFirstResponder()
    }
}


// MARK: - Memory Handle

private extension MessagesViewController {
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MessagesViewController.clearMemoryCache),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didReceiveMemoryWarningNotification,
                                                  object: nil)
    }
    
    @objc
    private func clearMemoryCache() {
        MessageStyle.bubbleImageCache.removeAllObjects()
    }
}

