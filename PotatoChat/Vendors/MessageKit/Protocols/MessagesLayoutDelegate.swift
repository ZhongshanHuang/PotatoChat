//
//  MessagesLayoutDelegate.swift
//  MessageExample
//
//  Created by 黄中山 on 2017/11/26.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import Foundation

/// A protocol used by the `MessagesCollectionViewFlowLayout` object to determine
/// the size and layout of a `MessageCollectionViewCell` and its contents.
protocol MessagesLayoutDelegate: AnyObject {
    
    /// Specifies the size to use for a header view.
    ///
    /// - Parameters:
    ///   - section: The section number of the header.
    ///   - messagesCollectionView: The `MessagesCollectionView` in which this header will be displayed.
    ///
    /// - Note:
    ///   The default value returned by this method is a size of `GGSize.zero`.
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize
    
    /// Specifies the size to use for a footer view.
    ///
    /// - Parameters:
    ///   - section: The section number of the footer.
    ///   - messagesCollectionView: The `MessagesCollectionView` in which this footer will be displayed.
    ///
    /// - Note:
    ///   The default value returned by this method is a size of `GGSize.zero`.
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize
    
    /// Specifies the size to use for a typing indicator view.
    ///
    /// - Parameters:
    ///   - messagesCollectionView: The `MessagesCollectionView` in which this view will be displayed.
    ///
    /// - Note:
    ///   The default value returned by this method is the width of the `messagesCollectionView` and
    ///   a height of 52.
    func typingIndicatorViewSize(in messagesCollectionView: MessagesCollectionView) -> CGSize
    
    /// Specifies the top inset to use for a typing indicator view.
    ///
    /// - Parameters:
    ///   - messagesCollectionView: The `MessagesCollectionView` in which this view will be displayed.
    ///
    /// - Note:
    ///   The default value returned by this method is a top inset of 15.
    func typingIndicatorViewTopInset(in messagesCollectionView: MessagesCollectionView) -> CGFloat
    
    /// Specifies the height for the `MessageContentCell`'s top label.
    ///
    /// - Parameters:
    ///   - message: The `MessageType` that will be displayed for this cell.
    ///   - indexPath: The `IndexPath` of the cell.
    ///   - messagesCollectionView: The `MessagesCollectionView` in which this cell will be displayed.
    ///
    /// - Note:
    ///   The default value returned by this method is zero.
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat
    
    /// Specifies the height for the `MessageContentCell`'s bottom label.
    ///
    /// - Parameters:
    ///   - message: The `MessageType` that will be displayed for this cell.
    ///   - indexPath: The `IndexPath` of the cell.
    ///   - messagesCollectionView: The `MessagesCollectionView` in which this cell will be displayed.
    ///
    /// - Note:
    ///   The default value returned by this method is zero.
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat
    
    /// Specifies the height for the message bubble's top label.
    ///
    /// - Parameters:
    ///   - message: The `MessageType` that will be displayed for this cell.
    ///   - indexPath: The `IndexPath` of the cell.
    ///   - messagesCollectionView: The `MessagesCollectionView` in which this cell will be displayed.
    ///
    /// - Note:
    ///   The default value returned by this method is zero.
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat
    
    /// Specifies the height for the `MessageContentCell`'s bottom label.
    ///
    /// - Parameters:
    ///   - message: The `MessageType` that will be displayed for this cell.
    ///   - indexPath: The `IndexPath` of the cell.
    ///   - messagesCollectionView: The `MessagesCollectionView` in which this cell will be displayed.
    ///
    /// - Note:
    ///   The default value returned by this method is zero.
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat
    
    /// Custom cell size calculator for messages with MessageType.custom.
    ///
    /// - Parameters:
    ///   - message: The custom message
    ///   - indexPath: The `IndexPath` of the cell.
    ///   - messagesCollectionView: The `MessagesCollectionView` in which this cell will be displayed.
    ///
    /// - Note:
    ///   The default implementation will throw fatalError(). You must override this method if you are using messages with MessageType.custom.
    func customCellSizeCalculator(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CellSizeCalculator
}

extension MessagesLayoutDelegate {
    
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    
    func typingIndicatorViewSize(in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: messagesCollectionView.bounds.width, height: 48)
    }
    
    func typingIndicatorViewTopInset(in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 15
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func customCellSizeCalculator(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CellSizeCalculator {
        fatalError("Must return a CellSizeCalculator for MessageKind.custom(Any?)")
    }
}
