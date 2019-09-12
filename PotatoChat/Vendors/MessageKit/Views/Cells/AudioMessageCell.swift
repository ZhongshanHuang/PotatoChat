//
//  AudioMessageCell.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/9/6.
//  Copyright © 2019 黄中山. All rights reserved.
//

import UIKit
import AVFoundation

/// A subclass of `MessageContentCell` used to display video and audio messages.
class AudioMessageCell: MessageContentCell {
    
    /// The play button view to display on audio messages.
    lazy var playButton: UIButton = {
        let playButton = UIButton(type: .custom)
        let playImage = UIImage.messageKitImageWith(type: .play)
        let pauseImage = UIImage.messageKitImageWith(type: .pause)
        playButton.setImage(playImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        playButton.setImage(pauseImage?.withRenderingMode(.alwaysTemplate), for: .selected)
        return playButton
    }()
    
    /// The time duration lable to display on audio messages.
    lazy var durationLabel: UILabel = {
        let durationLabel = UILabel(frame: CGRect.zero)
        durationLabel.textAlignment = .right
        durationLabel.font = UIFont.systemFont(ofSize: 14)
        durationLabel.text = "0:00"
        return durationLabel
    }()
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.isHidden = true
        return activityIndicatorView
    }()
    
    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0.0
        return progressView
    }()
    
    // MARK: - Methods
    
    /// Responsible for setting up the constraints of the cell's subviews.
    func setupConstraints() {
        playButton.constraint(equalTo: CGSize(width: 25, height: 25))
        playButton.addConstraints(left: messageContainerView.leftAnchor, centerY: messageContainerView.centerYAnchor, leftConstant: 5)
        activityIndicatorView.addConstraints(centerY: playButton.centerYAnchor, centerX: playButton.centerXAnchor)
        durationLabel.addConstraints(right: messageContainerView.rightAnchor, centerY: messageContainerView.centerYAnchor, rightConstant: 15)
        progressView.addConstraints(left: playButton.rightAnchor, right: durationLabel.leftAnchor, centerY: messageContainerView.centerYAnchor, leftConstant: 5, rightConstant: 5)
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(playButton)
        messageContainerView.addSubview(activityIndicatorView)
        messageContainerView.addSubview(durationLabel)
        messageContainerView.addSubview(progressView)
        setupConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        progressView.progress = 0
        playButton.isSelected = false
        activityIndicatorView.stopAnimating()
        playButton.isHidden = false
        durationLabel.text = "0:00"
    }
    
    /// Handle tap gesture on contentView and its subviews.
    override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
        // compute play button touch area, currently play button size is (25, 25) which is hardly touchable
        // add 10 px around current button frame and test the touch against this new frame
        let playButtonTouchArea = CGRect(playButton.frame.origin.x - 10.0, playButton.frame.origin.y - 10, playButton.frame.size.width + 20, playButton.frame.size.height + 20)
        let translateTouchLocation = convert(touchLocation, to: messageContainerView)
        if playButtonTouchArea.contains(translateTouchLocation) {
            delegate?.didTapPlayButton(in: self)
        } else {
            super.handleTapGesture(gesture)
        }
    }
    
    // MARK: - Configure Cell
    
    override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        guard let dataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }
        
        let playButtonLeftConstraint = messageContainerView.constraints.filter { $0.identifier == "left" }.first
        let durationLabelRightConstraint = messageContainerView.constraints.filter { $0.identifier == "right" }.first
        
        if !dataSource.isFromCurrentSender(message: message) {
            playButtonLeftConstraint?.constant = 12
            durationLabelRightConstraint?.constant = -8
        } else {
            playButtonLeftConstraint?.constant = 5
            durationLabelRightConstraint?.constant = -15
        }
        
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        
        let tintColor = displayDelegate.audioTintColor(for: message, at: indexPath, in: messagesCollectionView)
        playButton.imageView?.tintColor = tintColor
        durationLabel.textColor = tintColor
        progressView.tintColor = tintColor
        
        displayDelegate.configureAudioCell(self, message: message)
        
        if case let .audio(audioItem) = message.kind {
            durationLabel.text = displayDelegate.audioProgressTextFormat(audioItem.duration, for: self, in: messagesCollectionView)
        }
    }
}

