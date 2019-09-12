//
//  MessagesCollectionView.swift
//  MessageExample
//
//  Created by 黄中山 on 2017/11/26.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import UIKit

class MessagesCollectionView: UICollectionView {
    
    // MARK: - Properties
    
    weak var messagesDataSource: MessagesDataSource?
    
    weak var messagesDisplayDelegate: MessagesDisplayDelegate?
    
    weak var messagesLayoutDelegate: MessagesLayoutDelegate?
    
    weak var messageCellDelegate: MessageCellDelegate?
    
    var showsDateHeaderAfterTimeInterval: TimeInterval = 60 * 5 // 5 minutes
    
    var isTypingIndicatorHidden: Bool {
        return messagesCollectionViewFlowLayout.isTypingIndicatorViewHidden
    }
    
    private var indexPathForLastItem: IndexPath? {
        let lastSection = numberOfSections - 1
        guard lastSection >= 0, numberOfItems(inSection: lastSection) > 0 else { return nil }
        return IndexPath(item: numberOfItems(inSection: lastSection) - 1, section: lastSection)
    }
    
    var messagesCollectionViewFlowLayout: MessagesCollectionViewFlowLayout {
        guard let layout = collectionViewLayout as? MessagesCollectionViewFlowLayout else {
            fatalError(MessageKitError.layoutUsedOnForeignType)
        }
        return layout
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        backgroundColor = .white
        registerReusableViews()
        setupGestureRecognizers()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(frame: .zero, collectionViewLayout: MessagesCollectionViewFlowLayout())
    }
    
    convenience init() {
        self.init(frame: .zero, collectionViewLayout: MessagesCollectionViewFlowLayout())
    }
    
    // MARK: - Methods
    
    private func registerReusableViews() {
        register(TextMessageCell.self)
        register(MediaMessageCell.self)
        register(LocationMessageCell.self)
        register(AudioMessageCell.self)
        register(ContactMessageCell.self)
        register(TypingIndicatorCell.self)
        register(MessageReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        register(MessageReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter)
    }
    
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tapGesture.delaysTouchesBegan = true
        addGestureRecognizer(tapGesture)
    }
    
    @objc
    func handleTapGesture(_ gesture: UIGestureRecognizer) {
        guard gesture.state == .ended else { return }
        
        let touchLocation = gesture.location(in: self)
        guard let indexPath = indexPathForItem(at: touchLocation) else { return }
        
        let cell = cellForItem(at: indexPath) as? MessageCollectionViewCell
        cell?.handleTapGesture(gesture)
    }
    
    func scrollToBottom(animated: Bool = false) {
        performBatchUpdates(nil) { _ in
            let collectionViewContentHeight = self.collectionViewLayout.collectionViewContentSize.height
            self.scrollRectToVisible(CGRect(0.0, collectionViewContentHeight - 1.0, 1.0, 1.0), animated: animated)
        }
    }
    
    func reloadDataAndKeepOffset() {
        // stop scrolling
        setContentOffset(contentOffset, animated: false)
        
        // calculate the offset and reloadData
        let beforeContentSize = contentSize
        reloadData()
        layoutIfNeeded()
        let afterContentSize = contentSize
        
        // reset the contentOffset after data is updated
        let newOffset = CGPoint(
            x: contentOffset.x + (afterContentSize.width - beforeContentSize.width),
            y: contentOffset.y + (afterContentSize.height - beforeContentSize.height))
        setContentOffset(newOffset, animated: false)
    }
    
    // MARK: - Typing Indicator API
    
    /// Notifies the layout that the typing indicator will change state
    ///
    /// - Parameters:
    ///   - isHidden: A Boolean value that is to be the new state of the typing indicator
    func setTypingIndicatorViewHidden(_ isHidden: Bool) {
        messagesCollectionViewFlowLayout.setTypingIndicatorViewHidden(isHidden)
    }
    
    /// A method that by default checks if the section is the last in the
    /// `messagesCollectionView` and that `isTypingIndicatorViewHidden`
    /// is FALSE
    ///
    /// - Parameter section
    /// - Returns: A Boolean indicating if the TypingIndicator should be presented at the given section
    func isSectionReservedForTypingIndicator(_ section: Int) -> Bool {
        return messagesCollectionViewFlowLayout.isSectionReservedForTypingIndicator(section)
    }
    
    // MARK: View Register/Dequeue
    
    /// Registers a particular cell using its reuse-identifier
    func register<T: UICollectionViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellWithReuseIdentifier: String(describing: T.self))
    }
    
    /// Registers a reusable view for a specific SectionKind
    func register<T: UICollectionReusableView>(_ reusableViewClass: T.Type, forSupplementaryViewOfKind kind: String) {
        register(reusableViewClass,
                 forSupplementaryViewOfKind: kind,
                 withReuseIdentifier: String(describing: T.self))
    }
    
    /// Registers a nib with reusable view for a specific SectionKind
    func register<T: UICollectionReusableView>(_ nib: UINib? = UINib(nibName: String(describing: T.self), bundle: nil), headerFooterClassOfNib headerFooterClass: T.Type, forSupplementaryViewOfKind kind: String) {
        register(nib,
                 forSupplementaryViewOfKind: kind,
                 withReuseIdentifier: String(describing: T.self))
    }
    
    /// Generically dequeues a cell of the correct type allowing you to avoid scattering your code with guard-let-else-fatal
    func dequeueReusableCell<T: UICollectionViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Unable to dequeue \(String(describing: cellClass)) with reuseId of \(String(describing: T.self))")
        }
        return cell
    }
    
    /// Generically dequeues a header of the correct type allowing you to avoid scattering your code with guard-let-else-fatal
    func dequeueReusableHeaderView<T: UICollectionReusableView>(_ viewClass: T.Type, for indexPath: IndexPath) -> T {
        let view = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: T.self), for: indexPath)
        guard let viewType = view as? T else {
            fatalError("Unable to dequeue \(String(describing: viewClass)) with reuseId of \(String(describing: T.self))")
        }
        return viewType
    }
    
    /// Generically dequeues a footer of the correct type allowing you to avoid scattering your code with guard-let-else-fatal
    func dequeueReusableFooterView<T: UICollectionReusableView>(_ viewClass: T.Type, for indexPath: IndexPath) -> T {
        let view = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: String(describing: T.self), for: indexPath)
        guard let viewType = view as? T else {
            fatalError("Unable to dequeue \(String(describing: viewClass)) with reuseId of \(String(describing: T.self))")
        }
        return viewType
    }
    
}
