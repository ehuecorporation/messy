//
//  AppDelegate.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2016/09/11.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import UIKit
import NCMB
import Firebase
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var userData = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // FireBaseに接続
        FIRApp.configure()
        // googlaAd
        GADMobileAds.configure(withApplicationID: "ca-app-pub-6182342774000237/6565894501")
        
        // mbのAPIキー
        NCMB.setApplicationKey("644a6ccf8f9fa7c5f792d301adf624a7fe6d7455996b92de01a46037a84723a5", clientKey: "4c5771973e8c4818e5296e2aed38d2325e0fdfaad584b5560200830eaf88add6")
            NCMBTwitterUtils.initialize(withConsumerKey: "UVGEnYxLfLudJlCEVwcMDHo2C", consumerSecret: "Ot5yjc9N7jTxYLCa52nV8eRYYVvcByXCsqMZMj0Rb7NVYeyyir")
        
        //ナビゲーションアイテムの色を変更
        UINavigationBar.appearance().tintColor = UIColor.white
        //ナビゲーションバーの背景を変更
        UINavigationBar.appearance().barTintColor = UIColor.init(red: 44/255, green: 150/255, blue: 26/255, alpha: 0.5)
        //ナビゲーションのタイトル文字列の色を変更
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        var flag = true
        
        if userData.object(forKey: "userName") != nil && userData.object(forKey: "userPass") != nil{
            var targetName = String()
            var targetPass = String()
            if let name = userData.object(forKey: "userName") {
                targetName = (name as? String)!
            }
            
            if let pass = userData.object(forKey: "userPass") {
                targetPass = (pass as? String)!
            }

            login(targetName, targetPass)
        }
        
        let storyboard:UIStoryboard =  UIStoryboard(name: "Main",bundle:nil)
        var viewController:UIViewController
        
        //表示するビューコントローラーを指定
        viewController = storyboard.instantiateViewController(withIdentifier: "MainView") as UIViewController
        
        window?.rootViewController = viewController
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }
    
    func login(_ targetName: String, _ targetPass: String){
        NCMBUser.logInWithUsername(inBackground: targetName, password: targetPass, block: {
            (user, error) in
            
            if error != nil {
                
            } else {
                
                if !self.userData.bool(forKey: "userName"){
                    //                        print(user!.userName)
                    //                        print(self.userData.object(forKey: "userName"))
                    if user!.userName != self.userData.object(forKey: "userName") as? String{
                        // 端末に入っているmessyのデータを削除
                        let appDomain = Bundle.main.bundleIdentifier
                        UserDefaults.standard.removePersistentDomain(forName: appDomain!)
                    }
                }
                
                //端末情報の更新
                self.userData.set(user!.userName, forKey: "userName")
                self.userData.set(targetPass, forKey: "userPass")
                self.userData.set(user!.mailAddress, forKey: "userMail")
                self.userData.set(user!.object(forKey: "userIcon"), forKey: "userIconFileName")
                let favList: [String] = user?.object(forKey: "favList") as! [String]
                let likeList: [String] = user?.object(forKey: "likeList") as! [String]
                self.userData.set( favList, forKey: "favorites")
                self.userData.set( likeList, forKey: "likes")
                self.userData.set( user!.object(forKey: "userSex"), forKey: "userSex")
                
                if !self.userData.bool(forKey: "userIcon") {
                    let mbs = NCMBSearch()
                    mbs.loadIcon()
                }
                
                if let userID = user!.objectId {
                    self.userData.register(defaults: ["userID": String()])
                    self.userData.set(userID, forKey: "userID")
                }
                self.userData.register(defaults: ["useCount": Bool()])
                self.userData.set(true, forKey: "useCount")
                self.userData.synchronize()
                
            }
            
        }) //loginWithUsername end
    }
}

