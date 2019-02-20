//
//  MapView.swift
//  Shared Map
//
//  Created by 看得见的阳光 on 2018/3/18.
//  Copyright © 2018年 Sunnyyi. All rights reserved.
//

import UIKit

class MapView: MAMapView {

    //显示用户位置的小蓝点
    var userLocationRepresentation = MAUserLocationRepresentation()
    
    //将地图切换为普通显示用户位置的状态，只跟踪用户的位置变化
    func toggleToNormalState() {
        
        //显示地图位置及跨度等,注意设定的先后次序
        self.centerCoordinate = self.userLocation.coordinate
        self.region.span = MACoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        self.userTrackingMode = .follow
        self.showsCompass = false
        self.isScrollEnabled = false //为了避免与侧滑手势产生冲突，此状态下将其关闭
    }
    
    //将地图切换为追踪状态，既跟踪方向又跟踪位置变化
    func toggleToTrackingState() {
        
        self.showsCompass = true
        self.compassOrigin = CGPoint.init(x: 15.0, y: 330.0)
        //这样使用该方法没有效果，必须关联控件使用
//        self.setCameraDegree(80, animated: true, duration: 0.5)
        self.region.span = MACoordinateSpan.init(latitudeDelta: 0.005, longitudeDelta: 0.005)
        self.userTrackingMode = .followWithHeading
        self.userLocationRepresentation.showsHeadingIndicator = true
        self.update(self.userLocationRepresentation)
        self.isScrollEnabled = true //追踪状态下打开该手势，便于用户查看周边信息
    }
    
    //更改并显示mapView
    func setAndShow(with subMapViews: [SubView]!) {
        //允许显示用户位置的开关
        self.showsUserLocation = true
        //将地图初始化为普通状态
        toggleToNormalState()
        //显示地图的子视图，即按钮，搜索栏等
        for subView in subMapViews{
            self.addSubview(subView)
            subView.setStyle()
        }
    }
}
