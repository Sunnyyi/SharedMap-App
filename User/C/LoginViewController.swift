//
//  LoginViewController.swift
//  Shared Map
//
//  Created by 看得见的阳光
//  Copyright © 2018年 Sunnyyi. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UIView!
    
    @IBOutlet weak var userNameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    let registerVC = mainStoryboard.instantiateViewController(withIdentifier: "RegisterViewController")
    
    @IBAction func registerButtonClicked(_ sender: UIButton) {
        self.present(registerVC, animated: true, completion: nil)
    }
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        if userNameField.text == "" || passwordField.text == ""{
            let hudOfIncomplete = MBProgressHUD.showAdded(to: self.view, animated: false)
            setStyle(of: hudOfIncomplete!, with: "请填写用户名和密码！")
        }
        else {
            let error = EMClient.shared().login(withUsername: userNameField.text, password: passwordField.text)
            if error == nil {
                let hudOfLoginSuccessed = MBProgressHUD.showAdded(to: self.view, animated: false)
                setStyle(of: hudOfLoginSuccessed!, with: "登录成功")
                    //在客户端保存用户信息
                if let mail = user?.mail{
                        user = User(islogined: true, userName: userNameField.text!, mail: mail)
                }
                //实现自动登录：即首次登录成功后，不需要再次调用登录方法，在下次 APP 启动时，SDK 会自动为您登录。并且如果您自动登录失败，也可以读取到之前的会话信息。
                EMClient.shared().options.isAutoLogin = true
                drawer.set()
                self.present(drawer.centerContainer, animated: true, completion: nil)
            }
            else {
                let hudOfLoginfailed = MBProgressHUD.showAdded(to: self.view, animated: false)
                setStyle(of: hudOfLoginfailed!, with: "登录失败或者您还未注册过该账号，请重新尝试或先注册")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 53
        
        let inputImage = UIImage.init(named: "line.png")
        textView.layer.contents = inputImage?.cgImage
        
        userNameField.clearButtonMode = UITextFieldViewMode.whileEditing
        passwordField.clearButtonMode = UITextFieldViewMode.whileEditing
        
        userNameField.delegate = self
        passwordField.delegate = self
    }

}

extension LoginViewController: UITextFieldDelegate {
    
    //MARK: 对多次使用的功能封装成的methods
    //设置提示框的提示文字和提示样式
    func setStyle(of alertHud: MBProgressHUD, with alertText: String) {
        alertHud.mode = .text
        alertHud.detailsLabelText = alertText
        alertHud.hide(true, afterDelay: 2)
    }
    
    //MARK: textField的代理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
