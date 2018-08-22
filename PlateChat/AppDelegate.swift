//
//  AppDelegate.swift
//  PlateChat
//
//  Created by cano on 2018/08/02.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Firebase
        if let options = FirebaseOptions(contentsOfFile: Constants.GoogleServiceInfoPlistPath) {
            FirebaseConfiguration.shared.setLoggerLevel(.min)
            FirebaseApp.configure(options: options)
            Messaging.messaging().delegate = self
        }

        //UITabBar.appearance().barTintColor = UIColor.hexStr(hexStr: "#40e0d0", alpha: 1.0)
        //ナビゲーションアイテムの色を変更
        UINavigationBar.appearance().tintColor = UIColor.white
        //ナビゲーションバーの背景を変更
        UINavigationBar.appearance().barTintColor = UIColor.hexStr(hexStr: "#40e0d0", alpha: 1.0)
        //ナビゲーションのタイトル文字列の色を変更
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.font: R.font.notoSansCJKjpSubBold(size: 15.0)!,
            .foregroundColor: UIColor.white]
        // remove bottom shadow
        UINavigationBar.appearance().shadowImage = UIImage()
        //UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        UIButton.appearance(whenContainedInInstancesOf: [UINavigationController.self]).tintColor = .white

        // 通知用処理
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { (granted, error) in
                if let err = error {
                    Log.error(err)
                    return
                }
                if granted {
                    Log.debug("通知許可")
                    center.delegate = self
                    DispatchQueue.main.async(execute: {
                        application.registerForRemoteNotifications()
                    })
                } else {
                    Log.debug("通知拒否")
                }
            })
        } else {
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // リモート通知
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString: String = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        Log.debug("deviceTokenString \(deviceTokenString)")
        //Messaging.messaging().apnsToken = deviceToken
    }

    // リモート通知を拒否したときの動作
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Log.debug("リモート通知の設定は拒否されました")
    }
}

extension AppDelegate: MessagingDelegate {
    // FireBase側で通知送信に必要な端末識別子を取得
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        Log.debug("Firebase registration token: \(fcmToken)")
        //UserDefaults.standard.set(fcmToken, forKey: UserService.fcmTokenName)
        AccountData.fcmToken = fcmToken
        UserService.setLastLogin()
    }
}

