//
//  ProfileViewController.swift
//  WeChat
//
//  Created by 黄中山 on 2017/11/21.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let logoutBtn = UIButton(type: .system)
        logoutBtn.frame.size = CGSize(width: 100, height: 60)
        logoutBtn.center = view.center
        logoutBtn.setTitle("退出登录", for: .normal)
        logoutBtn.addTarget(self, action: #selector(logoutBtnClick(_:)), for: .touchUpInside)
        view.addSubview(logoutBtn)
    }
    
    @objc
    private func logoutBtnClick(_ sender: UIButton) {
        EMClient.shared()?.logout(true, completion: { (_) in
            UIApplication.shared.keyWindow?.rootViewController = LoginViewController(autoLogin: false)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
