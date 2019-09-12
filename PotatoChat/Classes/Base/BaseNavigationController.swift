//
//  BaseNavigationController.swift
//  WeChat
//
//  Created by 黄中山 on 2017/11/21.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 设置bar的背景色
        navigationBar.barTintColor = UIColor(red: 26/255.0, green: 26/255.0, blue: 26/255.0, alpha: 1.0)
        
        // 返回按钮颜色
        navigationBar.tintColor = UIColor.white
        
        // 设置title文字颜色
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white,
                                             .font: UIFont.boldSystemFont(ofSize: 19)]
        
        // 设置bar半透明
        navigationBar.isTranslucent = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Push
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Autorate
    
    override var shouldAutorotate: Bool {
        return topViewController!.shouldAutorotate
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController!.supportedInterfaceOrientations
    }
    
    // MARK: - StatusBarStyle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController!.preferredStatusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        return topViewController!.prefersStatusBarHidden
    }


}
