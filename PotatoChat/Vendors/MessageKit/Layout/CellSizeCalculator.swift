//
//  CellSizeCalculator.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/1/7.
//  Copyright © 2019 黄中山. All rights reserved.
//

import Foundation

class CellSizeCalculator {
    
    weak var layout: UICollectionViewFlowLayout?
    
    init() {}
    
    func configure(attributes: UICollectionViewLayoutAttributes) {}
    
    func sizeForItem(at indexPath: IndexPath) -> CGSize { return .zero }
}
