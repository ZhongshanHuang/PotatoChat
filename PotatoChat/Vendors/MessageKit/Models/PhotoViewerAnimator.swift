//
//  ModalTransitionAnimator.swift
//  weibo
//
//  Created by 黄山哥 on 2017/9/10.
//  Copyright © 2017年 黄山哥. All rights reserved.
//

import UIKit

// MARK: - present专场动画协议
protocol PhotoViewerPresentDelegate: class {
    
    // 对应的imageview
    func imageViewForPresent(indexPath: IndexPath) -> UIImageView
    
    // 起始位置
    func photoViewerPresentFromRect(indexPath: IndexPath) -> CGRect
    
    // 目标位置
    func photoViewerPresentToRect(indexPath: IndexPath) -> CGRect
}

// MARK: - dismiss专场动画协议
protocol PhotoViewerDismissDelegate: class {
    
    // 对应的imageview
    func imageViewForPresent() -> UIImageView
    
    // imageView的indexPath
    func indexPathForDismiss() -> IndexPath
}

// MARK: - 转场动画子
class PhotoViewerAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum ModalTransitionType {
        case present
        case dismiss
    }
    
    private var transitionType: ModalTransitionType = .present
    private var indexPath: IndexPath?
    private weak var presentDelegate: PhotoViewerPresentDelegate?
    private weak var dismissDelegate: PhotoViewerDismissDelegate?
    
    
    func setDelegateParams(presentDelegate: PhotoViewerPresentDelegate,
                           indexPath: IndexPath,
                           dismissDelegate: PhotoViewerDismissDelegate) {
        self.presentDelegate = presentDelegate
        self.indexPath = indexPath
        self.dismissDelegate = dismissDelegate
    }
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view,
            let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view else { return }
        transitionContext.containerView.addSubview(toView)
        
        if transitionType == .present {
            guard let presentDelegate = presentDelegate, let indexPath = indexPath else { return }
            
            let background = UIView(frame: .zero)
            background.frame = transitionContext.containerView.bounds
            background.backgroundColor = UIColor(white: 0, alpha: 0.1)
            transitionContext.containerView.addSubview(background)
            
            let imageView = presentDelegate.imageViewForPresent(indexPath: indexPath)
            imageView.frame = presentDelegate.photoViewerPresentFromRect(indexPath: indexPath)
            transitionContext.containerView.addSubview(imageView)
            
            toView.isHidden = true
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseOut, animations: {
                imageView.frame = presentDelegate.photoViewerPresentToRect(indexPath: indexPath)
                background.backgroundColor = UIColor(white: 0, alpha: 1)
            }, completion: { (finish) in
                toView.isHidden = false
                background.removeFromSuperview()
                imageView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
            
        } else if transitionType == .dismiss {
            fromView.removeFromSuperview()
            guard let dismissDelegate = dismissDelegate else { return }
            
            let background = UIView(frame: .zero)
            background.frame = transitionContext.containerView.bounds
            background.backgroundColor = UIColor(white: 0, alpha: 1)
            transitionContext.containerView.addSubview(background)
            
            let imageView = dismissDelegate.imageViewForPresent()
            transitionContext.containerView.addSubview(imageView)
            let indexPath = dismissDelegate.indexPathForDismiss()
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseOut, animations: {
                imageView.frame = self.presentDelegate!.photoViewerPresentFromRect(indexPath: indexPath)
                background.backgroundColor = UIColor(white: 0, alpha: 0.3)
            }, completion: { (finish) in
                imageView.removeFromSuperview()
                background.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
        
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension PhotoViewerAnimator: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transitionType = .present
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionType = .dismiss
        return self
    }

}


