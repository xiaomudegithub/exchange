   //
//  AppDelegate.swift
//  viossvc
//
//  Created by yaowang on 2016/10/29.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import UIKit
import SVProgressHUD
import DKNightVersion
private let keychainItem:OEZKeychainItemWrapper = OEZKeychainItemWrapper(identifier: "com.yundian.trip.account", accessGroup:nil)   
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

  
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
  
        print(NSHomeDirectory())
        
       let string = String.init(format: "%@", UUID.getUUID())

        
        let model = GetDeviceKey()
        model.deviceId = string
        
        
        model.deviceResolution = "1136×640"
        model.deviceModel = UIDevice.current.model
        model.deviceName = UIDevice.current.systemName
        model.osVersion = UIDevice.current.systemVersion
        model.requestPath = "/api/device/register.json"
        
        if UserDefaults.standard.object(forKey: "deviceKey") == nil {
        
            HttpRequestManage.shared().postRequestModelWithJson(requestModel: model, reseponse: { (result) in
                
            
                let dic = result as! NSDictionary
//                UUID.save(String.init(format: "%d", dic["deviceKeyId"] as! Int64) , withKey: "deviceKeyId")
//                 UUID.save(dic["deviceKey"] as! String, withKey: "deviceKey")
                UserDefaults.standard.setValue(dic["deviceKeyId"], forKey: "deviceKeyId")
                UserDefaults.standard.setValue(dic["deviceKey"], forKey: "deviceKey")
            }) { (error) in
                
            }
        }
       

        appearance()
        AppDataHelper.instance().initData()
        AppServerHelper.instance().initServer()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
   
    

    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = deviceToken.description
        token = token.replacingOccurrences(of: " ", with: "")
        token = token.replacingOccurrences(of: "<", with: "")
        token = token.replacingOccurrences(of: ">", with: "")
#if true
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () in
            GeTuiSdk.registerDeviceToken(token)
        })
#endif
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        WXApi.handleOpen(url, delegate: AppServerHelper.instance())
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    
        let urlString = url.absoluteString
        if urlString.hasPrefix(AppConst.bundleId) {
           UPPaymentControl.default().handlePaymentResult(url, complete: { (code, data) in
                 let str : String = "\(code!)"
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConst.UnionPay.UnionErrorCode), object: str, userInfo:nil)
            })
        }else{
             WXApi.handleOpen(url, delegate: AppServerHelper.instance())
        }
        return true
    }
    
    fileprivate func appearance() {
        
        window?.dk_backgroundColorPicker = DKColorTable.shared().picker(withKey: AppConst.Color.main)
        let navigationBar:UINavigationBar = UINavigationBar.appearance() as UINavigationBar;
        navigationBar.shadowImage = UIImage.init(named: "nav_clear")
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white];
        navigationBar.isTranslucent = false;
        navigationBar.tintColor = UIColor.white;
        navigationBar.setBackgroundImage(UIImage.init(named: "nav_main"), for: .any, barMetrics: .default)
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), for:.default);
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent;
        UITableView.appearance().backgroundColor = AppConst.Color.C6;
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        SVProgressHUD.setMinimumDismissTimeInterval(2)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.window?.endEditing(true)
    }
//    func getUUID() -> String {
//        
//        if keychainItem.object(forKey: "DeviceToken") != nil{
//            
//            return (keychainItem.object(forKey: "DeviceToken") as? String)!
//            
//        }
//        keychainItem.setObject( (UIDevice.current.identifierForVendor?.uuidString)!, forKey: "DeviceToken")
//        
//        return (keychainItem.object(forKey: "DeviceToken") as? String)!
//    }
      
}


