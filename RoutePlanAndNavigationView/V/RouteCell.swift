//
//  RouteCell.swift
//  Shared Map
//
//  Created by 看得见的阳光
//  Copyright © 2018年 Sunnyyi. All rights reserved.
//

import UIKit

class RouteCell: UICollectionViewCell {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var requiredTime: UILabel!
    @IBOutlet var requiredMileage: UILabel!
    
    func setStyle(){
        self.title.textColor = UIColor.init(red: 107/255, green: 107/255, blue: 107/255, alpha: 1.0)
        self.title.backgroundColor = UIColor.init(red: 215/255, green: 215/255, blue: 215/255, alpha: 1.0)
        self.requiredTime.textColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1.0)
        self.requiredMileage.textColor = self.title.textColor
        self.layer.backgroundColor = UIColor.init(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0).cgColor
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = self.title.backgroundColor?.cgColor
    }
    
    func changeStyle() {
        self.title.textColor = UIColor.white
        self.title.backgroundColor = UIColor.init(red: 71/255, green: 127/255, blue: 255/255, alpha: 1.0)
        self.requiredTime.textColor = UIColor.init(red: 71/255, green: 127/255, blue: 255/255, alpha: 1.0)
        self.requiredMileage.textColor = UIColor.init(red: 71/255, green: 127/255, blue: 255/255, alpha: 1.0)
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.init(red: 71/255, green: 127/255, blue: 255/255, alpha: 1.0).cgColor
    }
}
