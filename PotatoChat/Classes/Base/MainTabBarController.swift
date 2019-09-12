//
//  BaseTabBarController.swift
//  WeChat
//
//  Created by 黄中山 on 2017/11/21.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 设置tabBarItem文字颜色
        tabBar.tintColor = UIColor(red: 31/255.0, green: 185/255.0, blue: 34/255.0, alpha: 1.0)
        
        // 添加子控制器
        addChildViewControllers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 添加子控制器
    private func addChildViewControllers() {
        addChildViewController(ChatListViewController(), title: "微信", imageName: "tabbar_mainframe")
        addChildViewController(ContactsViewController(), title: "通讯录", imageName: "tabbar_contacts")
        addChildViewController(DiscoverViewController(), title: "发现", imageName: "tabbar_discover")
        addChildViewController(ProfileViewController(), title: "我", imageName: "tabbar_me")
    }
    
    private func addChildViewController(_ vc: UIViewController, title: String, imageName : String) {
        vc.title = title
        vc.tabBarItem = UITabBarItem(title: title,
                                     image: UIImage(named: imageName),
                                     selectedImage: UIImage(named: imageName + "_selected")?.withRenderingMode(.alwaysOriginal))
        let nv = BaseNavigationController(rootViewController: vc)
        addChild(nv)
    }

    
    // MARK: - Autorate
    override var shouldAutorotate: Bool {
        return selectedViewController?.shouldAutorotate ?? false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return selectedViewController?.supportedInterfaceOrientations ?? .portrait
    }

    // MARK: - StatusBarStyle
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return selectedViewController?.preferredStatusBarStyle ?? .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        return selectedViewController?.prefersStatusBarHidden ?? false
    }
    
}
