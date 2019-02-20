//
//  DetailRouteCell.swift
//  Shared Map
//
//  Created by 看得见的阳光
//  Copyright © 2018年 Sunnyyi. All rights reserved.
//

import UIKit

class DetailRouteCell: UITableViewCell {

    
    @IBOutlet var anctionImage: UIImageView!
    @IBOutlet var roadName: UILabel!
    @IBOutlet var stepDistance: UILabel! 
    @IBOutlet var showDetailImage: UIImageView!
    @IBOutlet var detailStep: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
