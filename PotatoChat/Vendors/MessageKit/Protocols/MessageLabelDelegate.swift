//
//  MessageLabelDelegate.swift
//  MessageExample
//
//  Created by 黄中山 on 2017/11/28.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import Foundation

/// A protocol used to handle tap events on detected text.
protocol MessageLabelDelegate: AnyObject {
    
    /// Triggered when a tap occurs on a detected address.
    ///
    /// - Parameters:
    ///   - addressComponents: The components of the selected address.
    func didSelectAddress(_ addressComponents: [String: String])
    
    /// Triggered when a tap occurs on a detected date.
    ///
    /// - Parameters:
    ///   - date: The selected date.
    func didSelectDate(_ date: Date)
    
    /// Triggered when a tap occurs on a detected phone number.
    ///
    /// - Parameters:
    ///   - phoneNumber: The selected phone number.
    func didSelectPhoneNumber(_ phoneNumber: String)
    
    /// Triggered when a tap occurs on a detected URL.
    ///
    /// - Parameters:
    ///   - url: The selected URL.
    func didSelectURL(_ url: URL)
    
    /// Triggered when a tap occurs on detected transit information.
    ///
    /// - Parameters:
    ///   - transitInformation: The selected transit information.
    func didSelectTransitInformation(_ transitInformation: [String: String])
    
    /// Triggered when a tap occurs on a mention
    ///
    /// - Parameters:
    ///   - mention: The selected mention
    func didSelectMention(_ mention: String)
    
    /// Triggered when a tap occurs on a hashtag
    ///
    /// - Parameters:
    ///   - mention: The selected hashtag
    func didSelectHashtag(_ hashtag: String)
    
    /// Triggered when a tap occurs on a custom regular expression
    ///
    /// - Parameters:
    ///   - pattern: the pattern of the regular expression
    ///   - match: part that match with the regular expression
    func didSelectCustom(_ pattern: String, match: String?)
    
}

extension MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {}
    
    func didSelectDate(_ date: Date) {}
    
    func didSelectPhoneNumber(_ phoneNumber: String) {}
    
    func didSelectURL(_ url: URL) {}
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {}
    
    func didSelectMention(_ mention: String) {}
    
    func didSelectHashtag(_ hashtag: String) {}
    
    func didSelectCustom(_ pattern: String, match: String?) {}
    
}
