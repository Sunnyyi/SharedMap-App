//
//  MapViewController.swift
//  Shared Map
//
//  Created by 看得见的阳光
//  Copyright © 2018年 Sunnyyi. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MapView!
    
    @IBOutlet var subMapViews: [SubView]!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var gpsButton: GPSButton!
    @IBOutlet weak var setButton: UIButton!
    
    //懒加载，将search和compositeManager推迟到使用时再进行初始化，能够优化内存的使用
    private lazy var search: AMapSearchAPI! = {
        let search = AMapSearchAPI()
        search?.delegate = self
        return search
    }()
    
    private lazy var compositeManager: AMapNaviCompositeManager! = {
        let compositeManager = AMapNaviCompositeManager()
        compositeManager.delegate = self
        return compositeManager
    }()
    
    //MARK: 关键字按钮点击时的事件处理
    @IBAction func foodButtonClicked(_ sender: UIButton) {
        keywordsButtonClicked(sender: sender)
    }
    
    @IBAction func gasStationButtonClicked(_ sender: UIButton) {
       keywordsButtonClicked(sender: sender)
    }
    
    @IBAction func toiletButtonClicked(_ sender: UIButton) {
        keywordsButtonClicked(sender: sender)
    }
    
    @IBAction func busStationClicked(_ sender: UIButton) {
        keywordsButtonClicked(sender: sender)
    }
    
    @IBAction func hospitalButtonClicked(_ sender: UIButton) {
        keywordsButtonClicked(sender: sender)
    }
    
    //MARK: gpsButton被点击时的事件处理
    @IBAction func gpsButtonClicked(_ sender: GPSButton) {
        let currentImage = sender.currentImage
        sender.changeState(of: mapView, base: currentImage!)
    }
    
    //MARK: chatButton被点击时的事件处理
    @IBAction func chatButtonClicked(_ sender: UIButton) {
        drawer.centerContainer.toggle(.left, animated: true, completion: nil)
    }
    
    //MARK: setButton被点击时的事件处理
    @IBAction func setButtonClicked(_ sender: UIButton) {
        let setView: SubView = settingView()!
        setView.isHidden = false
        setView.layer.cornerRadius = 10.0
    }
    
    //MARK: standardButton、satelliteButton、exitButton被点击时的事件处理
    @IBAction func standardButtonClicked(_ sender: UIButton) {
        mapView.mapType = .standard
    }
    @IBAction func satelliteButtonClicked(_ sender: UIButton) {
        mapView.mapType = .satellite
    }
    @IBAction func exitButtonClicked(_ sender: UIButton) {
        let error:EMError? = EMClient.shared().logout(true)
        if error == nil {
            NSLog("退出成功")
            //退出到登陆界面
            self.present(mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController"), animated: true, completion: nil)
        }
        else{
            print("退出失败")
        }
    }
    
    //MARK: 页面启动时的动作
    override func viewDidLoad () {
        super.viewDidLoad()
        mapView.setAndShow(with: subMapViews)
        mapView.delegate = self
        searchBar.delegate = self
        //为了和模型中的gpsButton中的数据一致，在此，单独设置gpsButton的Image
        gpsButton.backToNormal()
    }
    
    //隐藏地图视图及其子视图导航栏
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}


//扩展MapViewController,主要处理与用户的各种交互，实现各个控件的代理
extension MapViewController: MAMapViewDelegate, UISearchBarDelegate, AMapSearchDelegate, AMapNaviCompositeManagerDelegate {

    //MARK: 对多次使用的功能封装成的methods
    //当关键字按钮按下时，统一处理
    func keywordsButtonClicked(sender: UIButton) {
        searchBar.text = sender.title(for: .normal)
        keywordsSearch()
        quitKeywordsSearch()
    }
    //进行关键字搜索
    func keywordsSearch() {
        let request = AMapPOIKeywordsSearchRequest()
        let location = AMapGeoPoint.location(withLatitude: CGFloat(mapView.userLocation.coordinate.latitude), longitude: CGFloat(mapView.userLocation.coordinate.longitude))
        request.keywords = searchBar.text
        request.requireExtension = true
        request.location = location
        request.requireSubPOIs = true
        mapView.isScrollEnabled = true
        search.aMapPOIKeywordsSearch(request)
    }
    
    //退出关键字搜索，即使软键盘和keywordsView同时消失
    func quitKeywordsSearch() {
        keywordsView()?.isHidden = true
        searchBar.resignFirstResponder()
        
        if searchBar.text == "" {
            mapView.removeAnnotations(mapView.annotations)
            mapView.isScrollEnabled = false
        }
    }
    
    //获取keywordsView,方便以后直接访问
    func keywordsView() ->SubView? {
        for subView in subMapViews{
            if subView.restorationIdentifier == "KeywordsView"{
                return subView
            }
        }
        return nil
    }
    
    //获取settingView,方便以后直接访问
    func settingView() ->SubView? {
        for subView in subMapViews{
            if subView.restorationIdentifier == "SettingView"{
                return subView
            }
        }
        return nil
    }
    
    //MARK: 编写mapView的代理，处理mapView有关的事件
    
    //单击地图回调，返回经纬度
    func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        
        if gpsButton.currentImage != GPSState.normal {
            gpsButton.backToNormal()
        }
        
        if keywordsView()?.isHidden != true {
            quitKeywordsSearch()
        }
        
        let setView: SubView = settingView()!
        if setView.isHidden == false {
            setView.isHidden = true
        }
    }
    
    //地图将要被用户缩放时调用此接口
    func mapView(_ mapView: MAMapView!, mapWillZoomByUser wasUserAction: Bool) {
        
        if keywordsView()?.isHidden != true {
            quitKeywordsSearch()
        }
    }
    
    //当在地图上添加Annotation时调用此方法
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        //不再重复绘制系统小蓝点
        if annotation.coordinate.latitude != mapView.userLocation.coordinate.latitude && annotation.coordinate.longitude != mapView.userLocation.coordinate.longitude{
            if annotation.isKind(of: MAPointAnnotation.self) {
                let pointReuseIndetifier = "pointReuseIndetifier"
                var annotationView: MAPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as! MAPinAnnotationView?
                
                if annotationView == nil {
                    annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
                }
                
                annotationView!.canShowCallout = true
                annotationView!.animatesDrop = true
                annotationView!.isDraggable = true
                
                let goButton = UIButton.init(type: .detailDisclosure)
                goButton.setImage(UIImage.init(named: "airPlane.png"), for: .normal)
                annotationView!.rightCalloutAccessoryView = goButton

                return annotationView!
            }
        }
        return nil
    }
    
    //单击AnnotationView的气泡时调用此方法，进入导航界面
    func mapView(_ mapView: MAMapView!, annotationView view: MAAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        let config = AMapNaviCompositeUserConfig.init()
        let latitude = view.annotation.coordinate.latitude
        let longitude = view.annotation.coordinate.longitude
        let location = AMapNaviPoint.location(withLatitude: CGFloat(latitude), longitude: CGFloat(longitude))
        let name = view.annotation.title
        config.setRoutePlanPOIType(.end, location: location!, name: name, poiId: nil)
        compositeManager.presentRoutePlanViewController(withOptions: config)
    }
    
    //MARK: 编写searchBar的代理，处理searchBar有关的事件
    //当开始进行关键字搜索时，弹出keywordsView
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        keywordsView()?.isHidden = false
    }
    
    //用户点击软键盘的搜索按钮后调用此接口，开启关键字检索
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //使软键盘消失
        searchBar.resignFirstResponder()
        keywordsSearch()
    }
    
    //MARK: 编写search的代理，处理与关键字检索search有关的事件
    //关键字检索成功时调用，利用POI信息在地图上绘制出点标记
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        //释放上一次用户进行关键字检索时绘制的点标记
        mapView.removeAnnotations(mapView.annotations)
        
        if response.count == 0{
            return
        }
        
        var annos = Array<MAPointAnnotation>()
        
        for poi in response.pois{
            let pointAnnotation = MAPointAnnotation()
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(poi.location.latitude), longitude: CLLocationDegrees(poi.location.longitude))
            pointAnnotation.title = poi.name
            pointAnnotation.subtitle = poi.address
            annos.append(pointAnnotation)
        }
        mapView.addAnnotations(annos)
        mapView.showAnnotations(annos, animated: false)
        mapView.selectAnnotation(annos.first, animated: true)
    }
}
