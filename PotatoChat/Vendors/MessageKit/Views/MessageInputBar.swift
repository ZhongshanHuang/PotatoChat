//
//  MessageInputBar.swift
//  WeChat
//
//  Created by 黄中山 on 2018/1/11.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit

class MessageInputBar: UIView {
    
    // MARK: - Properties
    weak var delegate: MessageInputBarDelegate?
    
    private var lastClickButtonType: MessageInputBarButtonType = .none
    
    private var textHeight: CGFloat = 0
    
    private var maxTextHeight: CGFloat = 77 // 3行文字的高度

    private var isReachedMaxHeight: Bool = false
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.isScrollEnabled = false
        textView.scrollsToTop = false
        textView.showsHorizontalScrollIndicator = false
        textView.enablesReturnKeyAutomatically = true
        textView.returnKeyType = .send
        textView.delegate = self
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        return textView
    }()
    
    private lazy var voiceButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "ToolViewInputVoice"), for: .normal)
        button.setImage(UIImage(named: "ToolViewInputVoiceHL"), for: .highlighted)
        button.addTarget(self, action: #selector(clickVoiceButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var emoticonButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "ToolViewEmoticon"), for: .normal)
        button.setImage(UIImage(named: "ToolViewEmoticonHL"), for: .highlighted)
        button.addTarget(self, action: #selector(clickEmoticonButton), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "ToolViewKeyboard"), for: .normal)
        button.setImage(UIImage(named: "ToolViewKeyboardHL"), for: .highlighted)
        button.addTarget(self, action: #selector(clickMoreButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializers
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        setupSubviews()
        setupConstraints()
        addGestureRecognizer()
        addObserver()
    }
    
    deinit {
        removeObserver()
    }
    
    // 代码保证inputBar返回初始正常高度
    func reset() {
        textView.text = String()
        isReachedMaxHeight = false
        invalidateIntrinsicContentSize()
    }
    
    
    private func setupSubviews() {
        backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        addSubview(voiceButton)
        addSubview(textView)
        addSubview(emoticonButton)
        addSubview(moreButton)
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 8.5
        let textPadding: CGFloat = 4
        let itemWidth: CGFloat = 30
        
        voiceButton.translatesAutoresizingMaskIntoConstraints = false
        voiceButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: padding).isActive = true
        voiceButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: -textPadding).isActive = true
        voiceButton.widthAnchor.constraint(equalToConstant: itemWidth).isActive = true
        voiceButton.heightAnchor.constraint(equalToConstant: itemWidth).isActive = true
        
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -padding).isActive = true
        moreButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: -textPadding).isActive = true
        moreButton.widthAnchor.constraint(equalToConstant: itemWidth).isActive = true
        moreButton.heightAnchor.constraint(equalToConstant: itemWidth).isActive = true
        
        emoticonButton.translatesAutoresizingMaskIntoConstraints = false
        emoticonButton.rightAnchor.constraint(equalTo: moreButton.leftAnchor, constant: -padding/2).isActive = true
        emoticonButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: -textPadding).isActive = true
        emoticonButton.widthAnchor.constraint(equalToConstant: itemWidth).isActive = true
        emoticonButton.heightAnchor.constraint(equalToConstant: itemWidth).isActive = true
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: self.topAnchor, constant: textPadding).isActive = true
        textView.leftAnchor.constraint(equalTo: voiceButton.rightAnchor, constant: padding).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -UIApplication.shared.windows[0].safeAreaInsets.bottom - textPadding).isActive = true
        textView.rightAnchor.constraint(equalTo: emoticonButton.leftAnchor, constant: -padding).isActive = true
    }
    
    private func addGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        textView.addGestureRecognizer(tap)
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidHide(_:)),
                                               name: UIResponder.keyboardDidHideNotification,
                                               object: nil)
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods

    @objc
    private func textChange() {
        let textViewHeight = ceil(textView.sizeThatFits(CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)).height)
        
        // 如果超过了最大高度
        if textViewHeight - maxTextHeight > 1 {
            isReachedMaxHeight = true
            textView.isScrollEnabled = true
            // 不能超过最大高度
            invalidateIntrinsicContentSize()
            return
        } else if abs(textViewHeight - textHeight) > 1 { // 数据被删除
            invalidateIntrinsicContentSize()
        }
        
        textView.isScrollEnabled = false
        isReachedMaxHeight = false
        if abs(textHeight - textViewHeight) > 1 {
            textHeight = textViewHeight
            delegate?.messageInputBar(self, didChangeIntrinsicContentTo: CGSize(width: bounds.width, height: textViewHeight))
        }
    }
    
    override var intrinsicContentSize: CGSize {
        if isReachedMaxHeight {
            return CGSize(width: bounds.width, height: textHeight + 8 + UIApplication.shared.windows[0].safeAreaInsets.bottom)
        }
        return calculateIntrinsicContentSize()
    }

    private func calculateIntrinsicContentSize() -> CGSize {
        var size = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude))
        size.width = bounds.width
        size.height += UIApplication.shared.windows[0].safeAreaInsets.bottom + 8
        return size
    }
    
    // MARK: - Selector
    
    @objc
    private func clickVoiceButton() {
        if lastClickButtonType == .voice { return }
        lastClickButtonType = .voice
        delegate?.messageInputBar(self, didSelectedButton: .voice)
    }
    
    @objc
    private func clickEmoticonButton() {
        if lastClickButtonType == .emoticon { return }
        lastClickButtonType = .emoticon
        delegate?.messageInputBar(self, didSelectedButton: .emoticon)
    }
    
    @objc
    private func clickMoreButton() {
        if lastClickButtonType == .more { return }
        lastClickButtonType = .more
        delegate?.messageInputBar(self, didSelectedButton: .more)
    }
    
    @objc
    private func tapGestureHandler() {
        if lastClickButtonType == .textView { return }
        lastClickButtonType = .textView
        delegate?.messageInputBar(self, didSelectedButton: .textView)
    }
    
    @objc
    private func keyboardDidHide(_ notification: Notification) {
        lastClickButtonType = .none
    }
}

extension MessageInputBar: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        textChange()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            delegate?.messageInputBar(self, didPressSendButtonWith: textView.text)
            return false
        }
        return true
    }
}

