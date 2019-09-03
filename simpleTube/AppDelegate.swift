//
//  AppDelegate.swift
//  Tiamat
//
//  Created by yo_i on 2018/01/16.
//  Copyright © 2018年 Open Resource Corporation. All rights reserved.
//

import UIKit
import AVFoundation
//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var backgroudOnceFlag = false
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        initApplication()
        log.info(#function)
        //storyboard抜き
        window = UIWindow(frame: UIScreen.main.bounds)
        
        //初期画面設定
        let rootView = SUListView()//ルート画面
        let navigationController = UINavigationController(rootViewController: rootView)
        window?.backgroundColor = UIColor.white
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        //ナビゲーションバーの背景色指定
        UINavigationBar.appearance().backgroundColor = UIColor.white
        
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        log.info(#function)
        //キャッシュ削除(画像更新されない場合の対応)
        URLCache.shared.removeAllCachedResponses()
        
        
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        log.info(#function)
        backgroudOnceFlag = true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        log.info(#function)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        log.info(#function)
        backgroudOnceFlag = false
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        log.info(#function)
    }


}

