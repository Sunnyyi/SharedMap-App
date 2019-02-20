//
//  PathInformation.swift
//  Shared Map
//
//  Created by 看得见的阳光
//  Copyright © 2018年 Sunnyyi. All rights reserved.
//

import Foundation

struct PathInformation {
    
    let id: Int
    let title: String
    let length: String
    let time: String
    let path: AMapPath
    let pathSteps: Array<PathStep>
}
