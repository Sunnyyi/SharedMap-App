//
//  FriendsCellTableViewCell.swift
//  Shared Map
//
//  Created by 看得见的阳光
//  Copyright © 2018年 Sunnyyi. All rights reserved.
//

import UIKit

class FriendsCell: UITableViewCell {

    @IBOutlet var userName: UILabel!
    @IBOutlet var message: UILabel!
    @IBOutlet var addButton: UIButton!
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        let error: EMError? = EMClient.shared().contactManager.acceptInvitation(forUsername: userName.text)
        if error == nil {
            print("发送同意成功")
            friendsList.append(userName.text!)
            receivedNoticeMessage = false
            sender.isUserInteractionEnabled = false
            sender.setTitle("已添加", for: UIControlState.normal)
            sender.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
            sender.setBackgroundImage(UIImage.init(named: "white.png"), for: .normal)
            let userIndex = newNotices.index{ (userName, message) -> Bool in
                if userName == self.userName.text{
                    return true
                }
                return false
            }
            if let userIndex = userIndex{
                newNotices.remove(at: userIndex)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
