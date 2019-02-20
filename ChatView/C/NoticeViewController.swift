//
//  NoticeViewController.swift
//  Shared Map
//
//  Created by 看得见的阳光
//  Copyright © 2018年 Sunnyyi. All rights reserved.
//

import UIKit

var newNotices = Array<(username: String, message:String)>()
var oldNotices = Array<(username: String, message:String, isSuccess: Bool)>()
class NoticeViewController: UIViewController {

    @IBOutlet var noticeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //监听加好友回调
        //注册好友回调
        self.navigationItem.title = "申请与通知"
        EMClient.shared().contactManager.add(self, delegateQueue: nil)
        //移除好友回调
        EMClient.shared().contactManager.removeDelegate(self)
        noticeTableView.delegate = self
        noticeTableView.dataSource = self
        print(newNotices)
        noticeTableView.reloadData()
    }
}

extension NoticeViewController: EMContactManagerDelegate, UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newNotices.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frameRect = CGRect.init(x: 0, y: 0, width: 100, height: 40)
        let label = UILabel.init(frame: frameRect)
        switch section{
        case 0: label.text = "申请"
        case 1: label.text = "通知"
        default:
            break
        }
        return label
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "FriendsCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? FriendsCell
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: identifier) as? FriendsCell
        }
        cell?.userName.text = newNotices[indexPath.row].username
        cell?.message.text = newNotices[indexPath.row].message
        cell?.addButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        cell?.addButton.setBackgroundImage(UIImage.init(named: "blue.png"), for: UIControlState.normal)
        cell?.addButton.setTitle("添加", for: UIControlState.normal)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
