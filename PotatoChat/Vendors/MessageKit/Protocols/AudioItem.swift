//
//  AudioItem.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/9/6.
//  Copyright © 2019 黄中山. All rights reserved.
//

import class AVFoundation.AVAudioPlayer

/// A protocol used to represent the data for an audio message.
protocol AudioItem {
    
    /// The url where the audio file is located.
    var url: URL { get }
    
    /// The audio file duration in seconds.
    var duration: Float { get }
    
    /// The size of the audio item.
    var size: CGSize { get }
    
}
