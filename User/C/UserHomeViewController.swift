//
//  UserHomeViewController.swift
//  Shared Map
//
//  Created by 看得见的阳光
//  Copyright © 2018年 Sunnyyi. All rights reserved.
//

import UIKit

class UserHomeViewController: UIViewController {

    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userName: UILabel!
    
    @IBAction func returnButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userName.text = EMClient.shared().currentUsername
    }
}
