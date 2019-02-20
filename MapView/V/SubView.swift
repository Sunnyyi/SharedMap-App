//
//  SubView.swift
//  Shared Map
//
//  Created by 看得见的阳光
//  Copyright © 2018年 Sunnyyi. All rights reserved.
//

import UIKit

class SubView: UIView {

    //设置View样式（阴影）
    func setStyle() {
        self.layer.shadowOffset = CGSize.init(width: 0, height: 2.5)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowColor = UIColor.lightGray.cgColor
    }
}
