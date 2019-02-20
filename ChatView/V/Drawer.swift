//
//  Drawer.swift
//  Shared Map
//
//  Created by 看得见的阳光
//  Copyright © 2018年 Sunnyyi. All rights reserved.
//

import Foundation
import UIKit

struct Drawer{
    
    var centerContainer: MMDrawerController!
    
    mutating func set() {
        
        //获取StoryBoard中控制器的实例对象
        let centerViewController = mainStoryboard.instantiateViewController(withIdentifier: "NavigationController")
        let leftViewController = mainStoryboard.instantiateViewController(withIdentifier: "ChatTabBarController")
        //设置抽屉开启手势、关闭手势、开启时用户是否能与主视图控制器互动
        centerContainer = MMDrawerController.init(center: centerViewController, leftDrawerViewController: leftViewController)
        centerContainer.openDrawerGestureModeMask = .all
        centerContainer.closeDrawerGestureModeMask = .all
        centerContainer.centerHiddenInteractionMode = .full
        centerContainer.setDrawerVisualStateBlock(setAnimate)
    }
    
    //设置动画，这里是设置打开侧栏透明度从0到1
    private func setAnimate(drawerController: MMDrawerController?, drawerSide: MMDrawerSide,percentVisible: CGFloat) {
        var sideDrawerViewController:UIViewController?
        if drawerSide == MMDrawerSide.left {
            sideDrawerViewController = drawerController?.leftDrawerViewController;
        }
        sideDrawerViewController?.view.alpha = percentVisible
    }
}
