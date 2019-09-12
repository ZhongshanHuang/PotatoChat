//
//  MessagesCollectionViewFlowLayout.swift
//  MessageExample
//
//  Created by 黄中山 on 2017/11/28.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import UIKit
import AVFoundation

/// The layout object used by `MessagesCollectionView` to determine the size of all
/// framework provided `MessageCollectionViewCell` subclasses.
class MessagesCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override class var layoutAttributesClass: AnyClass {
        return MessagesCollectionViewLayoutAttributes.self
    }
    
    /// The `MessagesCollectionView` that owns this layout object.
    var messagesCollectionView: MessagesCollectionView {
        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.layoutUsedOnForeignType)
        }
        return messagesCollectionView
    }
    
    /// The `MessagesDataSource` for the layout's collection view.
    var messagesDataSource: MessagesDataSource {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }
        return messagesDataSource
    }
    
    /// The `MessagesLayoutDelegate` for the layout's collection view.
    var messagesLayoutDelegate: MessagesLayoutDelegate {
        guard let messagesLayoutDelegate = messagesCollectionView.messagesLayoutDelegate else {
            fatalError(MessageKitError.nilMessagesLayoutDelegate)
        }
        return messagesLayoutDelegate
    }
    
    var itemWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return collectionView.frame.width - sectionInset.left - sectionInset.right
    }
    
    private(set) var isTypingIndicatorViewHidden: Bool = true
    
    // MARK: - Initializers
    
    override init() {
        super.init()
        setupView()
        setupObserver()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        setupObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Methods
    
    private func setupView() {
        sectionInset = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    }
    
    private func setupObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesCollectionViewFlowLayout.handleOrientationChange(_:)), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    // MARK: - Typing Indicator API
    
    /// Notifies the layout that the typing indicator will change state
    ///
    /// - Parameters:
    ///   - isHidden: A Boolean value that is to be the new state of the typing indicator
    func setTypingIndicatorViewHidden(_ isHidden: Bool) {
        isTypingIndicatorViewHidden = isHidden
    }
    
    /// A method that by default checks if the section is the last in the
    /// `messagesCollectionView` and that `isTypingIndicatorViewHidden`
    /// is FALSE
    ///
    /// - Parameter section
    /// - Returns: A Boolean indicating if the TypingIndicator should be presented at the given section
    func isSectionReservedForTypingIndicator(_ section: Int) -> Bool {
        return !isTypingIndicatorViewHidden && section == messagesCollectionView.numberOfSections - 1
    }
    
    // MARK: - Attributes
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributesArray = super.layoutAttributesForElements(in: rect) as? [MessagesCollectionViewLayoutAttributes] else {
            return nil
        }
        for attributes in attributesArray where attributes.representedElementCategory == .cell {
            let cellSizeCalculator = cellSizeCalculatorForItem(at: attributes.indexPath)
            cellSizeCalculator.configure(attributes: attributes)
        }
        return attributesArray
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath) as? MessagesCollectionViewLayoutAttributes else {
            return nil
        }
        if attributes.representedElementCategory == .cell {
            let cellSizeCalculator = cellSizeCalculatorForItem(at: attributes.indexPath)
            cellSizeCalculator.configure(attributes: attributes)
        }
        return attributes
    }
    
    // MARK: - Layout Invalidation
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return collectionView?.bounds.width != newBounds.width
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds)
        guard let flowLayoutContext = context as? UICollectionViewFlowLayoutInvalidationContext else { return context }
        flowLayoutContext.invalidateFlowLayoutDelegateMetrics = shouldInvalidateLayout(forBoundsChange: newBounds)
        return flowLayoutContext
    }
    
    @objc
    private func handleOrientationChange(_ notification: Notification) {
        invalidateLayout()
    }
    
    // MARK: - Cell Sizing
    
    lazy var textMessageSizeCalculator = TextMessageSizeCalculator(layout: self)
    lazy var attributedTextMessageSizeCalculator = TextMessageSizeCalculator(layout: self)
    lazy var emojiMessageSizeCalculator: TextMessageSizeCalculator = {
        let sizeCalculator = TextMessageSizeCalculator(layout: self)
        sizeCalculator.messageLabelFont = UIFont.systemFont(ofSize: sizeCalculator.messageLabelFont.pointSize * 2)
        return sizeCalculator
    }()
    lazy var photoMessageSizeCalculator = MediaMessageSizeCalculator(layout: self)
    lazy var videoMessageSizeCalculator = MediaMessageSizeCalculator(layout: self)
    lazy var locationMessageSizeCalculator = LocationMessageSizeCalculator(layout: self)
    lazy var audioMessageSizeCalculator = AudioMessageSizeCalculator(layout: self)
    lazy var contactMessageSizeCalculator = ContactMessageSizeCalculator(layout: self)
    lazy var typingIndicatorSizeCalculator = TypingCellSizeCalculator(layout: self)
    
    /// Note:
    /// - If you override this method, remember to call MessageLayoutDelegate's
    /// customCellSizeCalculator(for:at:in:) method for MessageKind.custom messages, if necessary
    /// - If you are using the typing indicator be sure to return the `typingIndicatorSizeCalculator`
    /// when the section is reserved for it, indicated by `isSectionReservedForTypingIndicator`
    func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        if isSectionReservedForTypingIndicator(indexPath.section) {
            return typingIndicatorSizeCalculator
        }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        switch message.kind {
        case .text:
            return textMessageSizeCalculator
        case .attributedText:
            return attributedTextMessageSizeCalculator
        case .emoji:
            return emojiMessageSizeCalculator
        case .photo:
            return photoMessageSizeCalculator
        case .video:
            return videoMessageSizeCalculator
        case .location:
            return locationMessageSizeCalculator
        case .audio:
            return audioMessageSizeCalculator
        case .contact:
            return contactMessageSizeCalculator
        case .custom:
            return messagesLayoutDelegate.customCellSizeCalculator(for: message, at: indexPath, in: messagesCollectionView)
        }
    }
    
    func sizeForItem(at indexPath: IndexPath) -> CGSize {
        let calculator = cellSizeCalculatorForItem(at: indexPath)
        return calculator.sizeForItem(at: indexPath)
    }
    
    /// Set `incomingAvatarSize` of all `MessageSizeCalculator`s
    func setMessageIncomingAvatarSize(_ newSize: CGSize) {
        messageSizeCalculators().forEach { $0.incomingAvatarSize = newSize }
    }
    
    /// Set `outgoingAvatarSize` of all `MessageSizeCalculator`s
    func setMessageOutgoingAvatarSize(_ newSize: CGSize) {
        messageSizeCalculators().forEach { $0.outgoingAvatarSize = newSize }
    }
    
    /// Set `incomingAvatarPosition` of all `MessageSizeCalculator`s
    func setMessageIncomingAvatarPosition(_ newPosition: AvatarPosition) {
        messageSizeCalculators().forEach { $0.incomingAvatarPosition = newPosition }
    }
    
    /// Set `outgoingAvatarPosition` of all `MessageSizeCalculator`s
    func setMessageOutgoingAvatarPosition(_ newPosition: AvatarPosition) {
        messageSizeCalculators().forEach { $0.outgoingAvatarPosition = newPosition }
    }
    
    /// Set `avatarLeadingTrailingPadding` of all `MessageSizeCalculator`s
    func setAvatarLeadingTrailingPadding(_ newPadding: CGFloat) {
        messageSizeCalculators().forEach { $0.avatarLeadingTrailingPadding = newPadding }
    }
    
    /// Set `incomingMessagePadding` of all `MessageSizeCalculator`s
    func setMessageIncomingMessagePadding(_ newPadding: UIEdgeInsets) {
        messageSizeCalculators().forEach { $0.incomingMessagePadding = newPadding }
    }
    
    /// Set `outgoingMessagePadding` of all `MessageSizeCalculator`s
    func setMessageOutgoingMessagePadding(_ newPadding: UIEdgeInsets) {
        messageSizeCalculators().forEach { $0.outgoingMessagePadding = newPadding }
    }
    
    /// Set `incomingCellTopLabelAlignment` of all `MessageSizeCalculator`s
    func setMessageIncomingCellTopLabelAlignment(_ newAlignment: LabelAlignment) {
        messageSizeCalculators().forEach { $0.incomingCellTopLabelAlignment = newAlignment }
    }
    
    /// Set `outgoingCellTopLabelAlignment` of all `MessageSizeCalculator`s
    func setMessageOutgoingCellTopLabelAlignment(_ newAlignment: LabelAlignment) {
        messageSizeCalculators().forEach { $0.outgoingCellTopLabelAlignment = newAlignment }
    }
    
    /// Set `incomingCellBottomLabelAlignment` of all `MessageSizeCalculator`s
    func setMessageIncomingCellBottomLabelAlignment(_ newAlignment: LabelAlignment) {
        messageSizeCalculators().forEach { $0.incomingCellBottomLabelAlignment = newAlignment }
    }
    
    /// Set `outgoingCellBottomLabelAlignment` of all `MessageSizeCalculator`s
    func setMessageOutgoingCellBottomLabelAlignment(_ newAlignment: LabelAlignment) {
        messageSizeCalculators().forEach { $0.outgoingCellBottomLabelAlignment = newAlignment }
    }
    
    /// Set `incomingMessageTopLabelAlignment` of all `MessageSizeCalculator`s
    func setMessageIncomingMessageTopLabelAlignment(_ newAlignment: LabelAlignment) {
        messageSizeCalculators().forEach { $0.incomingMessageTopLabelAlignment = newAlignment }
    }
    
    /// Set `outgoingMessageTopLabelAlignment` of all `MessageSizeCalculator`s
    func setMessageOutgoingMessageTopLabelAlignment(_ newAlignment: LabelAlignment) {
        messageSizeCalculators().forEach { $0.outgoingMessageTopLabelAlignment = newAlignment }
    }
    
    /// Set `incomingMessageBottomLabelAlignment` of all `MessageSizeCalculator`s
    func setMessageIncomingMessageBottomLabelAlignment(_ newAlignment: LabelAlignment) {
        messageSizeCalculators().forEach { $0.incomingMessageBottomLabelAlignment = newAlignment }
    }
    
    /// Set `outgoingMessageBottomLabelAlignment` of all `MessageSizeCalculator`s
    func setMessageOutgoingMessageBottomLabelAlignment(_ newAlignment: LabelAlignment) {
        messageSizeCalculators().forEach { $0.outgoingMessageBottomLabelAlignment = newAlignment }
    }
    
    /// Set `incomingAccessoryViewSize` of all `MessageSizeCalculator`s
    func setMessageIncomingAccessoryViewSize(_ newSize: CGSize) {
        messageSizeCalculators().forEach { $0.incomingAccessoryViewSize = newSize }
    }
    
    /// Set `outgoingAccessoryViewSize` of all `MessageSizeCalculator`s
    func setMessageOutgoingAccessoryViewSize(_ newSize: CGSize) {
        messageSizeCalculators().forEach { $0.outgoingAccessoryViewSize = newSize }
    }
    
    /// Set `incomingAccessoryViewPadding` of all `MessageSizeCalculator`s
    func setMessageIncomingAccessoryViewPadding(_ newPadding: HorizontalEdgeInsets) {
        messageSizeCalculators().forEach { $0.incomingAccessoryViewPadding = newPadding }
    }
    
    /// Set `outgoingAccessoryViewPadding` of all `MessageSizeCalculator`s
    func setMessageOutgoingAccessoryViewPadding(_ newPadding: HorizontalEdgeInsets) {
        messageSizeCalculators().forEach { $0.outgoingAccessoryViewPadding = newPadding }
    }
    
    /// Set `incomingAccessoryViewPosition` of all `MessageSizeCalculator`s
    func setMessageIncomingAccessoryViewPosition(_ newPosition: AccessoryPosition) {
        messageSizeCalculators().forEach { $0.incomingAccessoryViewPosition = newPosition }
    }
    
    /// Set `outgoingAccessoryViewPosition` of all `MessageSizeCalculator`s
    func setMessageOutgoingAccessoryViewPosition(_ newPosition: AccessoryPosition) {
        messageSizeCalculators().forEach { $0.outgoingAccessoryViewPosition = newPosition }
    }
    
    /// Get all `MessageSizeCalculator`s
    func messageSizeCalculators() -> [MessageSizeCalculator] {
        return [textMessageSizeCalculator,
                attributedTextMessageSizeCalculator,
                emojiMessageSizeCalculator,
                photoMessageSizeCalculator,
                videoMessageSizeCalculator,
                locationMessageSizeCalculator,
                audioMessageSizeCalculator,
                contactMessageSizeCalculator
        ]
    }
    
}
