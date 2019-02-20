//
//  RegisterViewController.swift
//  Shared Map
//
//  Created by 看得见的阳光
//  Copyright © 2018年 Sunnyyi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

var userInfo: Dictionary = ["uvarName" : "", "mail" : "", "password" : ""]

class RegisterViewController: UIViewController {

    @IBOutlet weak var textView: UIView!
    @IBOutlet var userNameField: UITextField!
    @IBOutlet var mailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var confirmPasswordField: UITextField!
    
    @IBAction func registerButtonClicked(_ sender: UIButton) {
        if userNameField.text == "" || mailField.text == "" || passwordField.text == "" || confirmPasswordField.text == "" {
            let hudOfIncomplete = MBProgressHUD.showAdded(to: self.view, animated: false)
            setStyle(of: hudOfIncomplete!, with: "填写信息不完整，不能注册!")
        }
        else {
            guard passwordField.text == confirmPasswordField.text else{
                let hudOfNotEqual = MBProgressHUD.showAdded(to: self.view, animated: false)
                setStyle(of: hudOfNotEqual!, with: "确认密码和密码不一致，请重新输入!")
                confirmPasswordField.text = ""
                return
            }
            //注册
            let error = EMClient.shared().register(withUsername: userNameField.text, password: passwordField.text)
            if error == nil {
                let hudOfRegisterSuccessed = MBProgressHUD.showAdded(to: self.view, animated: false)
                setStyle(of: hudOfRegisterSuccessed!, with: "注册成功")
                user?.mail = mailField.text!
                self.present(mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController"), animated: true, completion: nil)
            }
            else {
                let hudOfRegisterfailed = MBProgressHUD.showAdded(to: self.view, animated: false)
                setStyle(of: hudOfRegisterfailed!, with: "注册失败或者您已经注册过该账号，请重新尝试或直接登录")
            }
            
//
//            userInfo.updateValue(userNameField.text!, forKey: "userName")
//            userInfo["mail"] = mailField.text!
//            userInfo["password"] = passwordField.text!
//            for aUserinfo in userInfo {
//                print(aUserinfo.key, ":", aUserinfo.value)
//            }
////  let userInfo: Dictionary = ["userName" : userNameField.text!, "mail" : mailField.text!, "password" : passwordField.text!]
//            Alamofire.request("http:192.168.1.100:8888/register.php", method: .post, parameters: userInfo, encoding: JSONEncoding.default, headers: nil).validate().response(completionHandler: {
//                response in
//                for data in (response.request?.allHTTPHeaderFields)!{
//                    print(data)
//                }
//                if let error = response.error{
//                     debugPrint(error)
//                }
//                else{
//                    debugPrint("没有错误!")
//                    debugPrint(response)
//                }
//            }
//            )
        }
    }
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        
        self.present(mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController"), animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let inputImage = UIImage.init(named: "multiLine.png")
        textView.layer.contents = inputImage?.cgImage
        
        userNameField.delegate = self
        mailField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
    }
}

extension RegisterViewController: UITextFieldDelegate {
    
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
