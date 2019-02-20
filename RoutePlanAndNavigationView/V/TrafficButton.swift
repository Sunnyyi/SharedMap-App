//
//  TrafficView.swift
//  Shared Map
//
//  Created by 看得见的阳光
//  Copyright © 2018年 Sunnyyi. All rights reserved.
//

import UIKit

class TrafficButton: UIButton {

    static let trafficState: Dictionary<String, UIImage> = [
        "On" : UIImage.init(named: "trafficOn.png")!,
        "Off" : UIImage.init(named: "trafficOff.png")!
    ]
    
    func setState(useImage image: UIImage) {
        self.setImage(image, for: .normal)
    }
    
    func backToNormal() {
        self.setState(useImage: TrafficButton.trafficState["Off"]!)
    }
    
    //gps按钮按下时同步切换mapView和gpsButton的状态
    func changeState(of naviView: MapView) {
        
        if naviView.isShowTraffic == false{
            naviView.isShowTraffic = true
            self.setState(useImage: TrafficButton.trafficState["On"]!)
            let hudOfTrafficOn = MBProgressHUD.showAdded(to: naviView, animated: false)
            hudOfTrafficOn?.mode = .text
            hudOfTrafficOn?.labelText = "开启并更新实时路况"
            hudOfTrafficOn?.hide(true, afterDelay: 2)
        }
        else{
            naviView.isShowTraffic = false
            self.backToNormal()
            let hudOfTrafficOff = MBProgressHUD.showAdded(to: naviView, animated: false)
            hudOfTrafficOff?.mode = .text
            hudOfTrafficOff?.labelText = "关闭实时路况"
            hudOfTrafficOff?.hide(true, afterDelay: 2)
        }
    }
}
