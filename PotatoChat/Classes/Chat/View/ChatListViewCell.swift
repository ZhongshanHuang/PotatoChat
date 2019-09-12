//
//  ChatViewCel.swift
//  WeChat
//
//  Created by 黄中山 on 2018/1/8.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit

class ChatListViewCell: UICollectionViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var detailsLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var badgeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        badgeLabel.layer.cornerRadius = 7.5
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        badgeLabel.layer.cornerRadius = 7.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(with chatModel: Conversation) {
        imageView.image = UIImage(named: "peiqi")
        titleLabel.text = chatModel.userid
        detailsLabel.text = chatModel.messageContent
        dateLabel.text = chatModel.timeToString()
        if chatModel.unreadCounts > 0 {
            badgeLabel.isHidden = false
            badgeLabel.text = "\(chatModel.unreadCounts)"
        } else {
            badgeLabel.isHidden = true
        }
    }

}
