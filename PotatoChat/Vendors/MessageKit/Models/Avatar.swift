//
//  Avatar.swift
//  MessageExample
//
//  Created by 黄中山 on 2017/11/25.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import UIKit

struct Avatar {
    
    // MARK: - Properties
    
    let image: UIImage?
    
    var initials: String = "?"
    
    init(image: UIImage? = nil, initials: String = "?") {
        self.image = image
        self.initials = initials
    }
}
