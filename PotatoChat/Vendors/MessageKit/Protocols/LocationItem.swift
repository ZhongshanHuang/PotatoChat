//
//  LocationItem.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/1/7.
//  Copyright © 2019 黄中山. All rights reserved.
//

import CoreLocation.CLLocation

protocol LocationItem {
    
    var location: CLLocation { get }
    
    var size: CGSize { get }
}
