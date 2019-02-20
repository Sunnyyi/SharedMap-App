//
//  AppDelegate.swift
//  Shared Map
//
//  Created by 看得见的阳光
//  Copyright © 2018年 Sunnyyi. All rights reserved.
//

import UIKit
import CoreData
import Alamofire


//由于每一个Controller都需要访问抽屉类，故设置为全局变量
var drawer = Drawer()
var gestureCounts: Int = 0
//获取StoryBoard,从而获取各个控制器的实体，方便对其进行操作
let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
var user: User?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let APIKey = "cff0264b96090f634bb3ee1d6aa21423"
    let options = EMOptions.init(appkey: "1138180324099367#sharedmap")
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        AMapServices.shared().enableHTTPS = true
        //配置高德key
        AMapServices.shared().apiKey = APIKey
        
        //配置环信key
        EMClient.shared().initializeSDK(with: options)
    
        let error = EMClient.shared().initializeSDK(with: options)
        if error == nil {
            print("初始化成功")
        }
        
        drawer.set()
        let isAutoLogin = EMClient.shared().options.isAutoLogin
        if isAutoLogin{
            self.window?.rootViewController = drawer.centerContainer
        }
        else{
            self.window?.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        }
        
        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    //App进入后台
    func applicationDidEnterBackground(_ application: UIApplication) {
        EMClient.shared().applicationDidEnterBackground(application)
    }

    //App将要从后台返回
    func applicationWillEnterForeground(_ application: UIApplication) {
        EMClient.shared().applicationWillEnterForeground(application)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Shared_Map")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
   
    //实现侧滑两次的不同效果
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        drawer.centerContainer.setGestureCompletionBlock(
            {
                (dc, gesture) in
                if gestureCounts == 2 {
                    gestureCounts = 0
                }
                else if gestureCounts < 2 {
                    gestureCounts = gestureCounts + 1
                }
            }
        )
        
        switch gestureCounts{
        case 1:
            drawer.centerContainer.maximumLeftDrawerWidth = 300
        case 2:
            drawer.centerContainer.maximumLeftDrawerWidth = 375
        default:
            break
        }
    }
}

