//
//  AddFriendsViewController.swift
//  Shared Map
//
//  Created by 看得见的阳光
//  Copyright © 2018年 Sunnyyi. All rights reserved.
//

import UIKit

class AddFriendsViewController: UIViewController {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var message: UITextView!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var friendsTableView: UITableView!
    
    let addTypes: Array<(type: String, image: UIImage)> = [("找人", UIImage.init(named: "foundPeople.png")!), ("找队伍",UIImage.init(named: "foundGroup.png")!)]
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        guard searchBar.text != "" else {
            let friendNameIsEmpty = MBProgressHUD.showAdded(to: self.view, animated: true)
            setStyle(of: friendNameIsEmpty!, with: "用户昵称不能为空!")
            return
        }
        
        guard message.text != "" else {
            let messageIsEmpty = MBProgressHUD.showAdded(to: self.view, animated: true)
            setStyle(of: messageIsEmpty!, with: "验证消息不能为空!")
            return
        }
        
        guard searchBar.text != EMClient.shared().currentUsername else{
            let addMyselfError = MBProgressHUD.showAdded(to: self.view, animated: true)
            setStyle(of: addMyselfError!, with: "不能添加自己！")
            return 
        }
        
        //获取好友列表
        var error: EMError? = nil
        let friendsList = EMClient.shared().contactManager.getContactsFromServerWithError(&error) as! Array<String>
        if error == nil {
            NSLog("获取成功 -- %@",friendsList)
        }
        
        if friendsList.contains(searchBar.text!){
            let hudOfRepeatedAddUser = MBProgressHUD.showAdded(to: self.view, animated: true)
            setStyle(of: hudOfRepeatedAddUser!, with: "您已成功添加过该好友！")
        }
        else{
            let error: EMError? = EMClient.shared().contactManager.addContact(searchBar.text, message: message.text)
            if error == nil {
                NSLog("发送申请成功")
                //发送成功后跳转到提示界面
                let addSuccessVC = mainStoryboard.instantiateViewController(withIdentifier: "AddSuccessViewController") as! AddSuccessViewController
                self.navigationController?.pushViewController(addSuccessVC, animated: true)
            }
            else{
                print("发送申请失败")
                let hudOfFailedToAddFriends = MBProgressHUD.showAdded(to: self.view, animated: true)
                setStyle(of: hudOfFailedToAddFriends!, with: "发送申请失败，网络原因或没有此用户存在。")
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
}

extension AddFriendsViewController:UISearchBarDelegate, UITableViewDataSource,UITableViewDelegate {
    
    //MARK: 对多次使用的功能封装成的methods
    //设置提示框的提示文字和提示样式
    func setStyle(of alertHud: MBProgressHUD, with alertText: String) {
        alertHud.mode = .text
        alertHud.detailsLabelText = alertText
        alertHud.hide(true, afterDelay: 2)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = friendsTableView.dequeueReusableCell(withIdentifier: "AddTypeCell") as? AddTypeCell
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "AddTypeCell") as? AddTypeCell
        }
        if searchBar.text != ""{
            cell?.label.text = "\(addTypes[indexPath.row].type): \(searchBar.text!)"
            cell?.imageField.image = addTypes[indexPath.row].image
        }
        return cell!
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        friendsTableView.reloadData()
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if (friendsTableView.cellForRow(at: indexPath) as! AddTypeCell).label.text == ""{
            return false
        }
        else{
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          //TODO: 实现用户搜索提示
        
    }
}
