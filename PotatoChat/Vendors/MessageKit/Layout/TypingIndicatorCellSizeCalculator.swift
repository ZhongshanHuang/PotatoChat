//
//  TypingIndicatorCellSizeCalculator.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/9/6.
//  Copyright © 2019 黄中山. All rights reserved.
//

import UIKit

class TypingCellSizeCalculator: CellSizeCalculator {
    
    var height: CGFloat = 62
    
    init(layout: MessagesCollectionViewFlowLayout? = nil) {
        super.init()
        self.layout = layout
    }
    
    override func sizeForItem(at indexPath: IndexPath) -> CGSize {
        guard let layout = layout else { return .zero }
        let collectionViewWidth = layout.collectionView?.bounds.width ?? 0
        let contentInset = layout.collectionView?.contentInset ?? .zero
        let inset = layout.sectionInset.horizontal + contentInset.horizontal
        return CGSize(width: collectionViewWidth - inset, height: height)
    }
}
