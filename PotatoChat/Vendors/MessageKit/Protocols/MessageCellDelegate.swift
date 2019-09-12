//
//  MessageCellDelegate.swift
//  MessageExample
//
//  Created by 黄中山 on 2017/11/28.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import Foundation

/// A protocol used by `MessageContentCell` subclasses to detect taps in the cell's subviews.
protocol MessageCellDelegate: MessageLabelDelegate {
    
    /// Triggered when a tap occurs in the background of the cell.
    ///
    /// - Parameters:
    ///   - cell: The cell where the tap occurred.
    ///
    /// - Note:
    /// You can get a reference to the `MessageType` for the cell by using `UICollectionView`'s
    /// `indexPath(for: cell)` method. Then using the returned `IndexPath` with the `MessagesDataSource`
    /// method `messageForItem(at:indexPath:messagesCollectionView)`.
    func didTapBackground(in cell: MessageCollectionViewCell)
    
    /// Triggered when a tap occurs in the `MessageContainerView`.
    ///
    /// - Parameters:
    ///   - cell: The cell where the tap occurred.
    ///
    /// - Note:
    /// You can get a reference to the `MessageType` for the cell by using `UICollectionView`'s
    /// `indexPath(for: cell)` method. Then using the returned `IndexPath` with the `MessagesDataSource`
    /// method `messageForItem(at:indexPath:messagesCollectionView)`.
    func didTapMessage(in cell: MessageCollectionViewCell)
    
    /// Triggered when a tap occurs in the `AvatarView`.
    ///
    /// - Parameters:
    ///   - cell: The cell where the tap occurred.
    ///
    /// You can get a reference to the `MessageType` for the cell by using `UICollectionView`'s
    /// `indexPath(for: cell)` method. Then using the returned `IndexPath` with the `MessagesDataSource`
    /// method `messageForItem(at:indexPath:messagesCollectionView)`.
    func didTapAvatar(in cell: MessageCollectionViewCell)
    
    /// Triggered when a tap occurs in the cellTopLabel.
    ///
    /// - Parameters:
    ///   - cell: The cell tap the touch occurred.
    ///
    /// You can get a reference to the `MessageType` for the cell by using `UICollectionView`'s
    /// `indexPath(for: cell)` method. Then using the returned `IndexPath` with the `MessagesDataSource`
    /// method `messageForItem(at:indexPath:messagesCollectionView)`.
    func didTapCellTopLabel(in cell: MessageCollectionViewCell)
    
    /// Triggered when a tap occurs in the cellBottomLabel.
    ///
    /// - Parameters:
    ///   - cell: The cell tap the touch occurred.
    ///
    /// You can get a reference to the `MessageType` for the cell by using `UICollectionView`'s
    /// `indexPath(for: cell)` method. Then using the returned `IndexPath` with the `MessagesDataSource`
    /// method `messageForItem(at:indexPath:messagesCollectionView)`.
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell)
    
    /// Triggered when a tap occurs in the messageTopLabel.
    ///
    /// - Parameters:
    ///   - cell: The cell tap the touch occurred.
    ///
    /// You can get a reference to the `MessageType` for the cell by using `UICollectionView`'s
    /// `indexPath(for: cell)` method. Then using the returned `IndexPath` with the `MessagesDataSource`
    /// method `messageForItem(at:indexPath:messagesCollectionView)`.
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell)
    
    /// Triggered when a tap occurs in the messageBottomLabel.
    ///
    /// - Parameters:
    ///   - cell: The cell where the tap occurred.
    ///
    /// You can get a reference to the `MessageType` for the cell by using `UICollectionView`'s
    /// `indexPath(for: cell)` method. Then using the returned `IndexPath` with the `MessagesDataSource`
    /// method `messageForItem(at:indexPath:messagesCollectionView)`.
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell)
    
    /// Triggered when a tap occurs in the accessoryView.
    ///
    /// - Parameters:
    ///   - cell: The cell where the tap occurred.
    ///
    /// You can get a reference to the `MessageType` for the cell by using `UICollectionView`'s
    /// `indexPath(for: cell)` method. Then using the returned `IndexPath` with the `MessagesDataSource`
    /// method `messageForItem(at:indexPath:messagesCollectionView)`.
    func didTapAccessoryView(in cell: MessageCollectionViewCell)
    
    /// Triggered when a tap occurs on the play button from audio cell.
    ///
    /// - Parameters:
    ///   - cell: The audio cell where the touch occurred.
    ///
    /// You can get a reference to the `MessageType` for the cell by using `UICollectionView`'s
    /// `indexPath(for: cell)` method. Then using the returned `IndexPath` with the `MessagesDataSource`
    /// method `messageForItem(at:indexPath:messagesCollectionView)`.
    func didTapPlayButton(in cell: AudioMessageCell)
    
    /// Triggered when audio player start playing audio.
    ///
    /// - Parameters:
    ///   - cell: The cell where the audio sound is playing.
    ///
    /// You can get a reference to the `MessageType` for the cell by using `UICollectionView`'s
    /// `indexPath(for: cell)` method. Then using the returned `IndexPath` with the `MessagesDataSource`
    /// method `messageForItem(at:indexPath:messagesCollectionView)`.
    func didStartAudio(in cell: AudioMessageCell)
    
    /// Triggered when audio player pause audio.
    ///
    /// - Parameters:
    ///   - cell: The cell where the audio sound is paused.
    ///
    /// You can get a reference to the `MessageType` for the cell by using `UICollectionView`'s
    /// `indexPath(for: cell)` method. Then using the returned `IndexPath` with the `MessagesDataSource`
    /// method `messageForItem(at:indexPath:messagesCollectionView)`.
    func didPauseAudio(in cell: AudioMessageCell)
    
    /// Triggered when audio player stoped audio.
    ///
    /// - Parameters:
    ///   - cell: The cell where the audio sound is stoped.
    ///
    /// You can get a reference to the `MessageType` for the cell by using `UICollectionView`'s
    /// `indexPath(for: cell)` method. Then using the returned `IndexPath` with the `MessagesDataSource`
    /// method `messageForItem(at:indexPath:messagesCollectionView)`.
    func didStopAudio(in cell: AudioMessageCell)
    
}

extension MessageCellDelegate {
    
    func didTapBackground(in cell: MessageCollectionViewCell) {}
    
    func didTapMessage(in cell: MessageCollectionViewCell) {}
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {}
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {}
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {}
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {}
    
    func didTapPlayButton(in cell: AudioMessageCell) {}
    
    func didStartAudio(in cell: AudioMessageCell) {}
    
    func didPauseAudio(in cell: AudioMessageCell) {}
    
    func didStopAudio(in cell: AudioMessageCell) {}
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {}
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {}
    
}
