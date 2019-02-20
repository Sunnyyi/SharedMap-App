//
//  PathStep.swift
//  Shared Map
//
//  Created by 看得见的阳光
//  Copyright © 2018年 Sunnyyi. All rights reserved.
//

import Foundation

struct PathStep{
    let actionImage: UIImage
    let roadName: String
    let distance: String
    let detailSteps: Array<(detailActionImage: UIImage, detailAction: String)>
}
