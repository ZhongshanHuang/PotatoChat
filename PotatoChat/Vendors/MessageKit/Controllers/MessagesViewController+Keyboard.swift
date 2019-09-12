//
//  MessagesViewController+Keyboard.swift
//  WeChat
//
//  Created by 黄山哥 on 2019/1/10.
//  Copyright © 2019 黄中山. All rights reserved.
//

import Foundation

extension MessagesViewController {
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MessagesViewController.handleKeyboardDidChangeState(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MessagesViewController.handleTextViewDidBeginEditing(_:)),
                                               name: UITextView.textDidBeginEditingNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MessagesViewController.adjustScrollViewTopInset),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillChangeFrameNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UITextView.textDidBeginEditingNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIDevice.orientationDidChangeNotification,
                                                  object: nil)
    }
    
    @objc
    private func handleKeyboardDidChangeState(_ notification: Notification) {
        // 获取目标frame
        let endRect = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int
        let offset = UIScreen.main.bounds.height - endRect.minY
        
        
        // 键盘缩回去的状态
        if (endRect.origin.y + endRect.height) > UIScreen.main.bounds.height {
            // 更新约束
            messageInputBarBottomConstraint?.constant = -offset
            // 动画
            UIView.animate(withDuration: duration) {
                UIView.setAnimationCurve(UIView.AnimationCurve(rawValue: curve)!)
                self.messageInputBar.superview?.layoutIfNeeded()
            }
            
            // 调整底部上升的幅度
            messageCollectionViewBottomInset = requiredInitialScrollViewBottomInset()
        } else { // 键盘显示出来的状态
            let afterBottomInset = endRect.height + messageInputBar.bounds.height - UIApplication.shared.windows[0].safeAreaInsets.bottom
            let differenceOfBottomInset = afterBottomInset - messageCollectionViewBottomInset
            let contentOffset = CGPoint(x: messagesCollectionView.contentOffset.x, y: messagesCollectionView.contentOffset.y + differenceOfBottomInset)
            
            if maintainPositionOnKeyboardFrameChanged {
                messagesCollectionView.setContentOffset(contentOffset, animated: false)
            }
            // 更新约束
            messageInputBarBottomConstraint?.constant = -(offset - UIApplication.shared.windows[0].safeAreaInsets.bottom)
            // 动画
            UIView.animate(withDuration: duration) {
                UIView.setAnimationCurve(UIView.AnimationCurve(rawValue: curve)!)
                self.messageInputBar.superview?.layoutIfNeeded()
            }
            // 调整底部上升的幅度
            messageCollectionViewBottomInset = afterBottomInset
        }
    }
    
    @objc
    private func handleTextViewDidBeginEditing(_ notification: Notification) {
        if scrollsToBottomOnKeybordBeginsEditing {
            messagesCollectionView.scrollToBottom(animated: true)
        }
    }

    @objc
    func adjustScrollViewTopInset() {
        let navigationBarInset = navigationController?.navigationBar.frame.height ?? 0
        let statusBarInset: CGFloat = UIApplication.shared.isStatusBarHidden ? 0 : UIApplication.shared.statusBarFrame.height
        let topInset = navigationBarInset + statusBarInset
        messagesCollectionView.contentInset.top = topInset
        messagesCollectionView.scrollIndicatorInsets.top = topInset
    }
    
    private func requiredScrollViewBottomInset(forKeyboardFrame keyboardFrame: CGRect) -> CGFloat {
        let intersection = messagesCollectionView.frame.intersection(keyboardFrame)
        
        if intersection.isNull || intersection.maxY < messagesCollectionView.frame.maxY {
            // The keyboard is hidden, is a hardware one, or is undocked and does not cover the bottom of the collection view.
            // Note: intersection.maxY may be less than messagesCollectionView.frame.maxY when dealing with undocked keyboards.
            return max(0, additionalBottomInset - automaticallyAddedBottomInset)
        } else {
            return max(0, intersection.height + additionalBottomInset - automaticallyAddedBottomInset)
        }
    }
    
    func requiredInitialScrollViewBottomInset() -> CGFloat {
        return max(0, messageInputBar.frame.height + additionalBottomInset)
    }
    
    private var automaticallyAddedBottomInset: CGFloat {
        if #available(iOS 11.0, *) {
            return messagesCollectionView.safeAreaInsets.bottom
        } else {
            return 0
        }
    }
}
