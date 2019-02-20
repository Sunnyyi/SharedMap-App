//
//  ChatTabBarController.swift
//  Shared Map
//
//  Created by 看得见的阳光
//  Copyright © 2018年 Sunnyyi. All rights reserved.
//

import UIKit

class ChatTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let items = self.tabBar.items{
            for anitem in items {
                anitem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.init(name: "Marion-Italic", size: 20) as Any], for: UIControlState.normal)
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
