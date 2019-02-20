//
//  FriendsViewController.swift
//  Shared Map
//
//  Created by 看得见的阳光
//  Copyright © 2018年 Sunnyyi. All rights reserved.
//

import UIKit

var receivedNoticeMessage: Bool?
var receivedGroupChatMessage: Bool?
var receivedChatRoomMessage: Bool?
var receivedFriendsMessage: Bool?
var friendsList = Array<String>()
class FriendsViewController: UIViewController {

    @IBOutlet var contactView: UITableView!
    @IBOutlet var userNameButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactView.delegate = self
        contactView.dataSource = self
        
        //获取当前登录用户的用户名并展示
        userNameButton.setTitle(EMClient.shared().currentUsername, for: .normal)
        
        //获取好友列表
        var error: EMError? = nil
        friendsList = EMClient.shared().contactManager.getContactsFromServerWithError(&error) as! Array<String>
        if error == nil {
            NSLog("获取成功 -- %@",friendsList)
        }
        //监听加好友回调
        //先注册
        EMClient.shared().contactManager.add(self, delegateQueue: nil)
        contactView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        contactView.reloadData()
    }
}

extension FriendsViewController: UITableViewDelegate,UITableViewDataSource, EMContactManagerDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            switch section{
            case 3:
                return friendsList.count
            default:
                return 1
            }
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "ContactCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ContactCell
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: identifier) as? ContactCell
        }

        switch indexPath.section {
        case 0:
            cell?.textLabel?.text = "申请与通知"
            if receivedNoticeMessage == true{
                cell?.noticeImage.image = UIImage.init(named: "redPoint.png")
            }
            else{
                cell?.noticeImage.image = UIImage.init()
            }
//            cell.imageView.image = [UIImage imageNamed:@"groupPublicHeader"];
        case 1:
            cell?.textLabel?.text = "队伍"
            if receivedGroupChatMessage == true{
                cell?.noticeImage.image = UIImage.init(named: "redPoint.png")
            }
        case 2:
            cell?.textLabel?.text = "聊天室"
            if receivedChatRoomMessage == true{
                cell?.noticeImage.image = UIImage.init(named: "redPoint.png")
            }
        case 3:
            cell?.imageView?.image = UIImage.init(named: "user.png")
            cell?.textLabel?.text = "    " + friendsList[indexPath.row]
//            cell.imageView.image = [UIImage imageNamed:@"chatListCellHead"];
        default:
            break
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section{
        case 0:
            self.navigationController?.pushViewController(mainStoryboard.instantiateViewController(withIdentifier: "NoticeViewController"), animated: true)
        case 1:
            self.navigationController?.pushViewController(mainStoryboard.instantiateViewController(withIdentifier: "GroupChatViewController"), animated: true)
        case 2:
           self.navigationController?.pushViewController(mainStoryboard.instantiateViewController(withIdentifier: "ChatRoomViewController"), animated: true)
        case 3:
            let aFriend = friendsList[indexPath.row]
            let chatVC = ChatViewController.init(conversationChatter: aFriend, conversationType: EMConversationTypeChat)
            chatVC?.title = aFriend //好友的名字
            chatVC?.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatVC!, animated: true)
        default:
            return
        }
    }
    
    /*!
     *  用户A发送加用户B为好友的申请，用户B会收到这个回调
     *
     *  @param aUsername   用户名
     *  @param aMessage    附属信息
     */
    func friendRequestDidReceive(fromUser aUsername: String!, message aMessage: String!) {
        receivedNoticeMessage = true
        if newNotices.contains(where: { (arg0) -> Bool in
            
            let (username, _) = arg0
            if aUsername == username{
                return true
            }
            return false
        }){
            return
        }
        else{
            newNotices.append((aUsername, aMessage))
        }
    }
    
    /*!
     @method
     @brief 用户A发送加用户B为好友的申请，用户B同意后，用户A会收到这个回调
     */
    func friendRequestDidApprove(byUser aUsername: String!) {
        //重新获取好友列表
        var error: EMError? = nil
        friendsList = EMClient.shared().contactManager.getContactsFromServerWithError(&error) as! Array<String>
        if error == nil{
            NSLog("获取成功 -- %@",friendsList)
        }
        contactView.reloadData()
    }
    
    /*!
     @method
     @brief 用户A发送加用户B为好友的申请，用户B拒绝后，用户A会收到这个回调
     */
    func friendRequestDidDecline(byUser aUsername: String!) {
        contactView.reloadData()
    }
}
