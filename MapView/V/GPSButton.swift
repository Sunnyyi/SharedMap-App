//
//  GPSButton.swift
//  Shared Map
//
//  Created by 看得见的阳光 on 2018/3/18.
//  Copyright © 2018年 Sunnyyi. All rights reserved.
//

import UIKit

class GPSButton: UIButton {
    
    //设置gpsButton显示图片
    private func setState(useImage image: UIImage) {
        self.setImage(image, for: .normal)
    }
    
    //使gpsButton回复到原始状态
    @objc func backToNormal(){
        self.setState(useImage: GPSState.normal)
    }
    
    //gps按钮按下时同步切换mapView和gpsButton的状态
    func changeState(of mapView: MapView, base gpsCurrentImage: UIImage) {
        switch gpsCurrentImage {
        case GPSState.normal:
            self.setState(useImage: GPSState.userLocate)
            mapView.toggleToNormalState()
        case GPSState.userLocate:
            self.setState(useImage: GPSState.userDetail)
            mapView.toggleToTrackingState()
            mapView.setCameraDegree(80, animated: true, duration: 0.5)
        case GPSState.userDetail:
            self.setState(useImage: GPSState.userLocate)
            mapView.toggleToNormalState()
        default:
            break
        }
    }


}
