//
//  MessageData.swift
//  MessageExample
//
//  Created by 黄中山 on 2017/11/25.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import UIKit
import CoreLocation.CLLocation

enum MessageKind {
    case text(String)
    
    /// A message with attributed text.
    case attributedText(NSAttributedString)
    
    /// A photo message.
    case photo(MediaItem)
    
    /// A video message.
    case video(MediaItem)
    
    /// A location message.
    case location(LocationItem)
    
    /// An emoji message.
    case emoji(String)
    
    /// An audio message.
    case audio(AudioItem)
    
    /// A contact message.
    case contact(ContactItem)
    
    /// A custom message.
    /// - Note: Using this case requires that you implement the following methods and handle this case:
    ///   - MessagesDataSource: customCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell
    ///   - MessagesLayoutDelegate: customCellSizeCalculator(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CellSizeCalculator
    case custom(Any?)
    
    // MARK: - Not supported yet
    
    //    case system(String)
    //
    //    case placeholder
}
