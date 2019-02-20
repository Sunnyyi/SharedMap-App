//
//  SearchHintViewController.swift
//  Shared Map
//
//  Created by 看得见的阳光
//  Copyright © 2018年 Sunnyyi. All rights reserved.
//

import UIKit

//负责路径规划和导航功能
class SearchHintViewController: UIViewController {

    @IBOutlet var selectionButtons: [UIButton]!
    @IBOutlet var startTextField: UITextField!
    @IBOutlet var endTextField: UITextField!
    
    @IBOutlet var searchView: SubView!
    
    @IBOutlet var tipView: SubView!
    @IBOutlet var searchHintView: UITableView!
    
    @IBOutlet var carButton: UIButton!
    @IBOutlet var busButton: UIButton!
    @IBOutlet var walkButton: UIButton!
    @IBOutlet var bikeButton: UIButton!
    
    @IBOutlet var routePlanView: SubView!
    @IBOutlet var routeView: UICollectionView!
    @IBOutlet var detailRouteView: UITableView!
    @IBOutlet var gpsNaviButton: UIButton!
    @IBOutlet var naviButtons: [UIButton]!
    @IBOutlet var startNaviView: SubView!
    @IBOutlet var showDetailButton: UIButton!
    
    @IBOutlet var naviView: MapView!
    @IBOutlet var subNaviViews: [SubView]!
    @IBOutlet var gpsButton: GPSButton!
    @IBOutlet var trafficButton: TrafficButton!
    @IBOutlet var chatButtonView: SubView!
    @IBOutlet var driveView: AMapNaviDriveView!
    
    
    //记录上一次点击cell时的indexPath
    private var indexMark = IndexPath.init(row: 0, section: 0)

    //用于存放规划成功时的多条路线的具体信息
    lazy var paths: Array<PathInformation> = {
        let paths = Array<PathInformation>()
        return paths
    }()
    
    //用于存放每条路线的步骤
    lazy var pathSteps: Array<PathStep> = {
        let pathSteps = Array<PathStep>()
        return pathSteps
    }()
    
    //用于存放每条路径的聚合路段名称,便于为每天路线步骤分段展示
    lazy var groupSegments: Array<Array<(road: String, sum: Int)>> = {
       let groupSegments = Array<Array<(road: String, sum: Int)>>()
        return groupSegments
    }()
    
    //记录第一次点击的Cell的indexPath
    var selectedCellIndexPaths = Array<IndexPath>()
    
    //MARK: gpsButton被点击时的事件处理
    @IBAction func gpsButtonClicked(_ sender: GPSButton) {
        sender.changeState(of: naviView, base: sender.currentImage!)
    }
    
    //MARK: chatButton被点击时的事件处理
    @IBAction func chatButtonClicked(_ sender: UIButton) {
        drawer.centerContainer.toggle(.left, animated: true, completion: nil)
    }
    
    //MARK: trafficButton被点击时的事件处理
    @IBAction func trafficButtonClicked(_ sender: TrafficButton) {
        sender.changeState(of: naviView)
    }
    
    @IBAction func showDetailButtonClicked(_ sender: UIButton) {
        showDetailRoute()
    }
    
    //懒加载，将search和tip变量推迟到使用时再进行初始化，能够优化内存的使用
    private lazy var search: AMapSearchAPI! = {
        let search = AMapSearchAPI()
        search?.delegate = self
        return search
    }()
    //用来存放提示搜索的结果
    struct TipLocation{
        let name: String
        let address: String
        let location: AMapGeoPoint
    }
    private lazy var tips: Array<TipLocation> = {
        let tips = Array<TipLocation>()
        return tips
    }()
    
    var userLocation: AMapGeoPoint?
    var startPoint: AMapGeoPoint?
    var endPoint: AMapGeoPoint?
    
    //用于标记当滑动searchHintView时正在编辑的textField
    private var editingTextFieldWhileScrolling: UITextField?
    
    //MARK: returnButton被点击时的事件处理
    @IBAction func returnButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: changeButton被点击时的事件处理
    @IBAction func changeButtonClicked(_ sender: UIButton) {
        let myLocation = startTextField.text
        if endTextField.text == "" {
            startTextField.text = nil
            startTextField.placeholder = "输入起点"
        }
        else{
            startTextField.text = endTextField.text
        }
        endTextField.text = myLocation
        endTextField.textColor = UIColor.black
    }
    
    //MARK: addFriendsButton被点击时的事件处理
    @IBAction func addFriendsButtonClicked(_ sender: UIButton) {
        drawer.centerContainer.toggle(.left, animated: true, completion: nil)
    }
    
    //MARK: driveButton被点击时的事件处理
    @IBAction func driveButtonClicked(_ sender: UIButton) {
        changeStyle(of: sender)
        startRoutePLan(in: sender)
    }
    
    //MARK: busButton被点击时的事件处理
    @IBAction func busButtonClicked(_ sender: UIButton) {
        changeStyle(of: sender)
        startRoutePLan(in: sender)
    }
    
    //MARK: walkButton被点击时的事件处理
    @IBAction func walkButtonClicked(_ sender: UIButton) {
        changeStyle(of: sender)
        startRoutePLan(in: sender)
    }
    
    //MARK: bikeButton被点击时的事件处理
    @IBAction func bikeButtonClicked(_ sender: UIButton) {
        changeStyle(of: sender)
        startRoutePLan(in: sender)
    }
    
    //MARK: 当GPS导航按钮按下时的事件处理
    @IBAction func gpsNaviButtonClicked(_ sender: UIButton) {
        startDriveNavigation()
        AMapNaviDriveManager.sharedInstance().startGPSNavi()
    }
    
    //MARK: 当模拟导航按钮按下时的事件处理
    @IBAction func emulatorNaviButtonClicked(_ sender: UIButton) {
        startDriveNavigation()
        AMapNaviDriveManager.sharedInstance().startEmulatorNavi()
    }
    
    
    //MARK: 页面启动时的事件处理
    override func viewDidLoad() {
        super.viewDidLoad()
        searchView.setStyle()
        
        startTextField.delegate = self
        endTextField.delegate = self
        
        searchHintView.delegate = self
        searchHintView.dataSource = self
    
        setRadius(of: naviButtons)
        setShadow(of: routePlanView, startNaviView)
        routeView.delegate = self
        routeView.dataSource = self
        detailRouteView.delegate = self
        detailRouteView.dataSource = self
        
        naviView.setAndShow(with: subNaviViews)
        gpsButton.backToNormal()
        trafficButton.backToNormal()
        naviView.delegate = self
        
        routePlanView.removeFromSuperview()
        
        driveView.delegate = self
    }
}

extension SearchHintViewController: AMapSearchDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, AMapNaviDriveViewDelegate {
    
    //MARK: 对多次使用的功能封装成的methods
    //根据路线步骤的动作生成步骤的指示图片
    func getStepImage(base action: String) -> UIImage {
        switch action{
        case "左转":
            return UIImage.init(named: "turnLeft.png")!
        case "右转":
            return UIImage.init(named: "turnRight.png")!
        case "向右前方行驶":
            return UIImage.init(named: "turnFrontRight.png")!
        case "向左前方行驶":
            return UIImage.init(named: "turnFrontLeft.png")!
        default:
            return UIImage.init()
        }
    }
    
    //当某个按钮按下时改变按钮的style，同时清除其它按钮的Style
    func changeStyle(of button: UIButton) {
        button.backgroundColor = UIColor.init(red: 69/255, green: 122/255, blue: 255/255, alpha: 1)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 15.0
        
        for abutton in selectionButtons{
            if abutton.restorationIdentifier != button.restorationIdentifier{
                abutton.backgroundColor = UIColor.white
                abutton.setTitleColor(UIColor.darkGray, for: .normal)
            }
        }
    }

    //发起输入提示语查询
    func inputPromptQuery(with keywords: String?) {
        let request = AMapInputTipsSearchRequest.init()
        request.keywords = keywords
        search.aMapInputTipsSearch(request)
    }
    
    //为提示搜索做准备
    func prepareForTipSearch() {
        tipView.layer.frame.origin = CGPoint.init(x: 0, y: 147)
        tipView.addSubview(searchHintView)
    }
    
    //发起驾车路线规划
    func startDriveRoutePlan() {
        let start = AMapNaviPoint.location(withLatitude: (startPoint?.latitude)!, longitude: (startPoint?.longitude)!)
        let end = AMapNaviPoint.location(withLatitude: (endPoint?.latitude)!, longitude: (endPoint?.longitude)!)
        AMapNaviDriveManager.sharedInstance().delegate = self
        AMapNaviDriveManager.sharedInstance().calculateDriveRoute(withStart: [start!], end: [end!], wayPoints: nil, drivingStrategy: AMapNaviDrivingStrategy(rawValue: 10)!)
        
        let request = AMapDrivingRouteSearchRequest()
        request.origin = startPoint
        request.destination = endPoint
        request.strategy = 10
        request.requireExtension = true
        search.aMapDrivingRouteSearch(request)
        
        
    }
    
    //发起驾车导航
    func  startDriveNavigation() {
        
        guard paths.count != 0 else{
            return
        }
        
        
        
        naviView.removeFromSuperview()
        searchView.removeFromSuperview()
        tipView.removeFromSuperview()
        
        self.view.addSubview(driveView)
        //重新创建AMapDriveManager的单例
        AMapNaviDriveManager.sharedInstance().allowsBackgroundLocationUpdates = true
        AMapNaviDriveManager.sharedInstance().pausesLocationUpdatesAutomatically = false
        
        //将driveView添加为导航数据的Representative，使其可以接收到导航诱导数据
        AMapNaviDriveManager.sharedInstance().addDataRepresentative(driveView)
    }
    
    //结束导航
    func finishNavigation() {
        driveView.removeFromSuperview()
        //销毁单例
        AMapNaviDriveManager.sharedInstance().stopNavi()
        AMapNaviDriveManager.sharedInstance().removeDataRepresentative(driveView)
        
        self.view.addSubview(naviView)
        self.view.addSubview(searchView)
        self.view.addSubview(tipView)
    }
    
    //进行不同方式的路径规划
    func startRoutePLan(in stateButton: UIButton) {
        if startTextField.text == "我的位置"{
            startPoint = userLocation
        }
        if startPoint != nil, endPoint != nil {
            searchHintView.removeFromSuperview()
            tipView.addSubview(routePlanView)
            tipView.layer.frame.origin = CGPoint.init(x: 0, y: 520)
            naviView.isScrollEnabled = true
            switch stateButton.restorationIdentifier {
            case "CarButton":
                startDriveRoutePlan()
            // TODO: 对导航方式进行扩展
            case "BusButton":
                break
            case "WalkButton":
                break
            case "BikeButton":
                break
            default:
                return
            }
            changeStyle(of: stateButton)
        }
    }
    
    //设置提示框的提示文字和提示样式
    func setStyle(of alertHud: MBProgressHUD, with alertText: String) {
        alertHud.mode = .text
        alertHud.labelText = alertText
        alertHud.hide(true, afterDelay: 2)
    }
    
    //获取当前正在编辑的textField
    func getEditingTextField() -> UITextField? {
        if startTextField.isEditing{
            return startTextField
        }
        else if endTextField.isEditing{
            return endTextField
        }
        
        return editingTextFieldWhileScrolling
    }
    
    //MARK: 编写search的代理，处理与输入提示语查询有关的事件
    //提示语搜索成功时触发调用
    func onInputTipsSearchDone(_ request: AMapInputTipsSearchRequest!, response: AMapInputTipsSearchResponse!) {
        
        if response.count == 0 {
            return
        }
        
        tips.removeAll()
        
        for tip in response.tips{
            if let name = tip.name, let address = tip.address, let location = tip.location {
                let tiplocation = TipLocation.init(name: name, address: address, location: location)
                tips.append(tiplocation)
            }
        }
        searchHintView.reloadData()
    }
    
    //FIXME: 搜索提示只能返回10条数据
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        print(error.localizedDescription)
        print("Error:\(error)")
    }
    
    //判断某条路径的某个分段路名是否为聚合路段
    func  getGroupIndex(of stepRoad: String, in pathID: Int) -> Int {
        var i = 0
        for stepName in groupSegments[pathID]{
            if stepRoad.contains(stepName.road){
                let j = groupSegments[pathID][i].sum
                groupSegments[pathID][i].sum = j + 1
                return i
            }
            i = i + 1
        }
        return -1
    }
    
    //MARK: 当检索成功时，会进到 onRouteSearchDone 回调函数中，在该回调中，通过解析 AMapRouteSearchResponse 获取将驾车规划路线的数据显示在地图上
    func onRouteSearchDone(_ request: AMapRouteSearchBaseRequest!, response: AMapRouteSearchResponse!) {
        if response.count == 0, groupSegments.count == 0 {
            return
        }
        
        var firstPath: AMapPath?
        paths.removeAll()
        naviView.removeOverlays(naviView.overlays)
        
        var id = 1
        for path in response.route.paths {
            let title = path.strategy
            let length = String.init(format: "%.1f", Double(path.distance)/1000.0) + "公里"
            let time: String
            if path.duration <= 3600 {
                time = "\(path.duration/60)分钟"
            }
            else{
                time = "\(path.duration/3600)小时\(path.duration%3600/60)分钟"
            }
            if id == 1 {
                firstPath = path
            }
            else {
                generatePolyline(with: (id, path))
            }
            
            pathSteps.removeAll()
            var detailSteps = Array<(detailActionImage: UIImage, detailAction: String)>()
            var distance = 0 //用于记录聚合路段的总里程数
            var sum = 0  //用于记录生成的聚合路段的个数
            var detailImage: UIImage?
            var lastInstruction: String?
            for step in path.steps{
                //若该StepRoad不为聚合路段，则添加到detailSteps数组中
                let groupIndex = getGroupIndex(of: step.road, in: (id-1))
                if groupIndex == -1 || groupSegments[(id-1)][groupIndex].sum == 2 {
                    distance = distance + step.distance
                    detailImage = getStepImage(base: step.action)
                    detailSteps.append((detailImage!, step.instruction))
                    lastInstruction = step.instruction
                }
                //若为聚合路段则将其聚合生成一个pathStep并添加到pathSteps中去
                else{
                    let actionImage = detailSteps[0].detailActionImage
                    let roadName = groupSegments[id-1][sum].road
                    let sumDistance: String
                    if distance >= 1000{
                        sumDistance = String.init(format: "%.1f", Double(distance)/1000.0) + "公里"
                    }
                    else{
                        sumDistance = "\(distance)米"
                    }
                    
                    //修改最后一个元素
                    if sum < groupSegments[id-1].count-1 {
                        detailSteps.removeLast()
                        detailSteps.append((detailImage!, lastInstruction! + "进入\(groupSegments[id-1][sum+1].road)"))
                        //聚合路段加1
                        sum = sum + 1
                    }
                    
                    let pathStep = PathStep.init(actionImage: actionImage, roadName: roadName, distance: sumDistance, detailSteps: detailSteps)
                    pathSteps.append(pathStep)
                    
                    //每生成一个聚合路段就清空相应的记录值，准备生成下一个
                    detailSteps.removeAll()
                    distance = 0
                    
                    //将本次相匹配的结果保存到下一个聚合路段数组中
                    distance = distance + step.distance
                    detailImage = getStepImage(base: step.action)
                    detailSteps.append((detailImage!, step.instruction))
                }
            }
            
            let pathInformation = PathInformation.init(id: id, title: title!, length: length, time: time, path: path, pathSteps: pathSteps)
            paths.append(pathInformation)
            id = id + 1
            
        }
        if firstPath != nil {
            generatePolyline(with: (1, firstPath!))
        }
        
        //FIXME: 数据出错
//        //MARK: 测试paths数组中的数据
//        var j = 1
//        for apath in paths{
//            print("第\(j)条路的导航步骤为: \n对应的聚合路段为: ")
//            for seg in groupSegments[(j-1)]{
//                print(seg)
//            }
//            for step in apath.path.steps{
//                print(step.instruction, step.road)
//            }
//            var i = 1
//            for step in apath.pathSteps{
//                print("第\(i)步为: \(step.roadName, step.distance)")
//                for detail in step.detailSteps{
//                    print("---\(detail.detailAction)")
//                }
//                i = i + 1
//            }
//            j = j + 1
//        }
        
        pathSteps = paths[0].pathSteps
        
        addBeginAndEndAnnotation()
        trafficButton.changeState(of: naviView)
        routeView.reloadData()
    }
    
    
    //编写driveManager的代理，处理driveManager有关的事件
    func driveManager(onCalculateRouteSuccess driveManager: AMapNaviDriveManager) {
        for naviRoute in driveManager.naviRoutes!{
            var pathSegment = Array<(road: String, sum: Int)>()
            for segment in naviRoute.value.routeGroupSegments{
                pathSegment.append((segment.groupName, 0))
            }
            groupSegments.append(pathSegment)
        }
    }
    
    func driveManager(_ driveManager: AMapNaviDriveManager, onArrivedWayPoint wayPointIndex: Int32) {
        NSLog("ArrivedWayPoint:\(wayPointIndex)");
    }
    
    //MARK: 编写textField的代理，处理与输入地址有关的事件
    //输入框获取焦点的'那一刻'触发调用
    func textFieldDidBeginEditing(_ textField: UITextField) {
        prepareForTipSearch()
    }
    //输入框获取焦点且输入文字不为空或输入的文字改变时触发调用
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        inputPromptQuery(with: textField.text)
        return true
    }
    //当输入框的搜索按钮点击时触发调用
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //根据用户的具体错误的操作情况向用户给出相对应的提示
        if startTextField.text == endTextField.text{
            if startTextField.text == ""{
                let hudOfKeywordsIsEmpty = MBProgressHUD.showAdded(to: searchHintView, animated: false)
                setStyle(of: hudOfKeywordsIsEmpty!, with: "搜索内容不能为空")
            }
            else{
                let hudOfKeywordsIsEqual = MBProgressHUD.showAdded(to: searchHintView, animated: false)
                setStyle(of: hudOfKeywordsIsEqual!, with: "起点和终点不能相等")
            }
        }
        else if startTextField.text == ""{
            let hudOfStartIsEmpty = MBProgressHUD.showAdded(to: searchHintView, animated: false)
            setStyle(of: hudOfStartIsEmpty!, with: "起点不能为空")
        }
        else if endTextField.text == ""{
            let hudOfEndIsEmpty = MBProgressHUD.showAdded(to: searchHintView, animated: false)
            setStyle(of: hudOfEndIsEmpty!, with: "终点不能为空")
        }
        return true
    }
    
    //MARK: 编写tableViewDataSourse的代理，处理与tableView的数据源有关的事件
    //以下两个方法必须要实现
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.restorationIdentifier{
        case "SearchHintView":
            return tips.count
        case "DetailRouteView":
            return pathSteps.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.restorationIdentifier{
        case "SearchHintView":
            var cell = searchHintView.dequeueReusableCell(withIdentifier: "TipCell") as? TipCell
            if cell == nil {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "TipCell") as? TipCell
            }
            cell?.tipName.text = tips[indexPath.row].name
            cell?.tipAddress.text = tips[indexPath.row].address
            return cell!
        case "DetailRouteView":
            var cell = detailRouteView.dequeueReusableCell(withIdentifier: "DetailRouteCell") as? DetailRouteCell
            if cell == nil {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "DetailRouteCell") as? DetailRouteCell
            }
            cell?.anctionImage.image = pathSteps[indexPath.row].actionImage
            cell?.roadName.text = pathSteps[indexPath.row].roadName
            cell?.stepDistance.text = pathSteps[indexPath.row].distance
            var detailStep = " "
            for detail in pathSteps[indexPath.row].detailSteps{
                detailStep = detailStep + detail.detailAction + "\n"
            }
            cell?.detailStep.text = detailStep
            cell?.detailStep.sizeToFit()
            if selectedCellIndexPaths.contains(indexPath) {
                cell?.showDetailImage.image = UIImage.init(named: "upArrow.png")
            }
            else{
                cell?.showDetailImage.image = UIImage.init(named: "downArrow.png")
            }
            return cell!
        default:
            return UITableViewCell.init()
        }
    }
    
    //MARK: 编写tableView的代理，处理与searchHintView有关的事件
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch tableView.restorationIdentifier{
        case "SearchHintView":
            let selectedTipName = (searchHintView.cellForRow(at: indexPath) as! TipCell).tipName.text
            let editingTextFied = getEditingTextField()
            editingTextFied?.text = selectedTipName
            editingTextFied?.resignFirstResponder()
            
            if editingTextFied == startTextField{
                startPoint = tips[indexPath.row].location
            }
            else if editingTextFied == endTextField{
                endPoint = tips[indexPath.row].location
            }
            
            if startTextField.text != endTextField.text {
                
                startRoutePLan(in: carButton)
            }
            else{
                let hudOfKeywordsIsEqual = MBProgressHUD.showAdded(to: searchHintView, animated: false)
                setStyle(of: hudOfKeywordsIsEqual!, with:  "起点和终点不能相等")
            }
        case "DetailRouteView":
            if let index = selectedCellIndexPaths.index(of: indexPath) {
                selectedCellIndexPaths.remove(at: index)
            }else{
                selectedCellIndexPaths.append(indexPath)
            }
            //以下方法将重新调用tableView的代理函数
            detailRouteView.reloadRows(at: [indexPath], with: .automatic)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.restorationIdentifier == "DetailRouteView"{
            if selectedCellIndexPaths.contains(indexPath) {
                return 200
            }
            return 80
        }
        return 60
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if startTextField.isEditing {
            editingTextFieldWhileScrolling = startTextField
            startTextField.resignFirstResponder()
        }
        else if endTextField.isEditing {
            editingTextFieldWhileScrolling = endTextField
            endTextField.resignFirstResponder()
        }
    }
    
    //MARK: 编写driveView的代理,处理与driveView有关的事件
    func driveViewCloseButtonClicked(_ driveView: AMapNaviDriveView) {
        finishNavigation()
    }
}


extension SearchHintViewController: UICollectionViewDelegate, UICollectionViewDataSource, MAMapViewDelegate, AMapNaviDriveManagerDelegate {
    
    //MARK: 对多次使用的功能封装成的methods
    //给routePlanView设置Shadow
    func  setShadow(of views: SubView...) {
        for view in views{
            view.layer.shadowOffset =  CGSize.init(width: 0, height: -1.0)
            view.layer.shadowOpacity = 1.0
            view.layer.shadowColor = UIColor.lightGray.cgColor
        }
    }
    
    //给所有naviButton设置圆角及边框颜色
    func setRadius(of naviButtons: [UIButton]!) {
        for button in naviButtons{
            button.layer.cornerRadius = 5.0
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.init(red: 71/255, green: 127/255, blue: 255/255, alpha: 1.0).cgColor
        }
    }
    
    //显示具体路线
    func showDetailRoute() {
        let originOfview = routePlanView.superview?.layer.frame.origin
        if originOfview?.y == 147{
            showDetailButton.setImage(UIImage.init(named: "detail-black.png"), for: .normal)
            routePlanView.superview?.layer.frame.origin = CGPoint.init(x: 0, y: 520)
            gpsNaviButton.isHidden = false
        }
        else{
            showDetailButton.setImage(UIImage.init(named: "showMap-black.png"), for: .normal)
            routePlanView.superview?.layer.frame.origin = CGPoint.init(x: 0, y: 147)
            gpsNaviButton.isHidden = true
        }
    }
    
    //添加路线起点和终点的标记
    func addBeginAndEndAnnotation() {
        naviView.removeAnnotations(naviView.annotations)
        let beginAnnotation = MAPointAnnotation.init()
        beginAnnotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees((startPoint?.latitude)!), longitude: CLLocationDegrees((startPoint?.longitude)!))
        beginAnnotation.title = "起点"
        naviView.addAnnotation(beginAnnotation)
        
        let endAnnotation = MAPointAnnotation.init()
        endAnnotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees((endPoint?.latitude)!), longitude: CLLocationDegrees((endPoint?.longitude)!))
        endAnnotation.title = "终点"
        naviView.addAnnotation(endAnnotation)
    }
    
    //根据具体路线的坐标点在地图上绘制线
    func generatePolyline(with path: (id: Int, value: AMapPath)) {
        
        //首先获取该路线的坐标点集
        var pathCoordinates = Array<CLLocationCoordinate2D>()
        for step in path.value.steps{
            let stepCoordinates = step.polyline.components(separatedBy: ";")
            for coordinate in stepCoordinates{
                let stepCoordinate = coordinate.components(separatedBy: ",")
                let longitude = Double(stepCoordinate[0])
                let latitude = Double(stepCoordinate[1])
                pathCoordinates.append(CLLocationCoordinate2D.init(latitude: latitude!, longitude: longitude!))
            }
        }
        //为该路线绘制
        let polyline = MAPolyline.init(coordinates: &pathCoordinates, count: UInt(pathCoordinates.count))
        if  path.id == 1 {
            polyline?.title = "推荐方案"
        }
        else{
            polyline?.title = "备选方案"
        }

        naviView.add(polyline)
        //地图缩放级别自适应
        naviView.setVisibleMapRect((polyline?.boundingMapRect)!, edgePadding: UIEdgeInsetsMake(40, 40, 40, 40), animated: true)
    }
    
    //MARK: 编写routeView的数据源，处理与路线数据显示有关的事件
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return paths.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = routeView.dequeueReusableCell(withReuseIdentifier: "RouteCell", for: indexPath) as?  RouteCell
        cell?.title.text = paths[indexPath.row].title
        cell?.requiredTime.text = paths[indexPath.row].time
        cell?.requiredMileage.text = paths[indexPath.row].length
        if indexPath.row == 0{
            cell?.changeStyle()
        }
        else{
            cell?.setStyle()
        }
        
        return cell!
    }
    
    //MARK: 编写routeView的代理，处理与routeView有关的事件
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (routeView.cellForItem(at: indexPath) as! RouteCell).changeStyle()
        if indexPath.row == indexMark.row{
            showDetailRoute()
        }
        else{
            indexMark = indexPath
            if indexPath.row != 0{
                (routeView.cellForItem(at: IndexPath.init(row: 0, section: 0)) as! RouteCell).setStyle()
                generatePolyline(with: (id: 2, value: paths[0].path))
            }
            generatePolyline(with: (id: 1, value: paths[indexPath.row].path))
        }
        
        pathSteps = paths[indexPath.row].pathSteps
        detailRouteView.reloadData()
    }
    
    //必须在已经被点击过一次以后才会被触发
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        (routeView.cellForItem(at: indexPath) as! RouteCell).setStyle()
        generatePolyline(with: (id: 2, value: paths[indexPath.row].path))
    }
    
    //MARK: 编写naviView的代理，处理naviView有关的事件
    func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        if gpsButton.currentImage != GPSState.normal {
            gpsButton.backToNormal()
        }
    }
    
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        self.userLocation = AMapGeoPoint.location(withLatitude: CGFloat(userLocation.coordinate.latitude), longitude: CGFloat(userLocation.coordinate.longitude))
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAPinAnnotationView? = naviView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as! MAPinAnnotationView?
            
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            annotationView!.canShowCallout = false
            annotationView!.animatesDrop = false
            if annotation.title == "起点" {
                annotationView?.image = UIImage.init(named: "beginPoint.png")
            }
            else if annotation.title == "终点" {
                annotationView?.image = UIImage.init(named: "endPoint.png")
            }
            return annotationView!
        }
        return nil
    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay.isKind(of: MAPolyline.self) {
            let polylineRender = MAPolylineRenderer.init(overlay: overlay)
            polylineRender?.lineWidth = 10.0
            polylineRender?.strokeColor = UIColor.green
            polylineRender?.fillColor = UIColor.green
            polylineRender?.lineJoinType = kMALineJoinRound
            if overlay.title == "推荐方案" {
                polylineRender?.strokeImage = UIImage.init(named: "lineTexture.png")
            }
            else if overlay.title == "备选方案" {
                polylineRender?.strokeImage = UIImage.init(named: "lineTexture-light.png")
            }
            return polylineRender
        }
        return nil
    }
}
