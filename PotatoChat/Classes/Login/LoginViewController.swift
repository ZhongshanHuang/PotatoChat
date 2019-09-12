//
//  LoginViewController.swift
//  WeChat
//
//  Created by 黄中山 on 2018/1/21.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    private var autoLogin: Bool = true
    
    convenience init(autoLogin: Bool = true) {
        self.init(nibName: nil, bundle: nil)
        self.autoLogin = autoLogin
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        usernameField.text = UserDefaults.standard.string(forKey: Constant.userNameKey)
        passwordField.text = UserDefaults.standard.string(forKey: Constant.passwordKey)
        if autoLogin {
            login()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc
    @IBAction func login() {
        if usernameField.text!.isEmpty {
            SVProgressHUD.showInfo(withStatus: "请输入用户名")
            usernameField.becomeFirstResponder()
        } else if passwordField.text!.isEmpty {
            SVProgressHUD.showInfo(withStatus: "请输入密码")
            passwordField.becomeFirstResponder()
        } else {
            EMClient.shared().login(withUsername: usernameField.text!, password: passwordField.text!) { (username, error) in
                if let error = error {
                    // 保存登录账号
                    UserDefaults.standard.set(self.usernameField.text, forKey: Constant.userNameKey)
                    // 提示错误
                    SVProgressHUD.showError(withStatus: error.errorDescription)
                } else {
                    // 跳转到聊天界面
                    UIApplication.shared.keyWindow?.rootViewController = MainTabBarController()
                    // 保存登录密码和账号
                    UserDefaults.standard.set(self.usernameField.text, forKey: Constant.userNameKey)
                    UserDefaults.standard.set(self.passwordField.text, forKey: Constant.passwordKey)
                    // 订阅服务器消息
                    MessageClient.shared.registerMessages()
                }
            }
        }
    }
    
    @objc
    @IBAction func register() {
        if usernameField.text!.isEmpty {
            SVProgressHUD.showInfo(withStatus: "请输入用户名")
            usernameField.becomeFirstResponder()
        } else if passwordField.text!.isEmpty {
            SVProgressHUD.showInfo(withStatus: "请输入密码")
            passwordField.becomeFirstResponder()
        } else {
            EMClient.shared().register(withUsername: usernameField.text!, password: passwordField.text!) { (username, error) in
                if let error = error {
                    SVProgressHUD.showError(withStatus: error.errorDescription)
                } else {
                    SVProgressHUD.showSuccess(withStatus: "注册成功，请登陆")
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
