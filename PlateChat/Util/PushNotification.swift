//
//  PushNotification.swift
//  PlateChat
//
//  Created by cano on 2018/08/28.
//  Copyright © 2018年 deskplate. All rights reserved.
//
// 参考：https://qiita.com/mshrwtnb/items/3135e931eedc97479bb5
// 通知用処理関連クラス
//

import Foundation
import UserNotifications
import Firebase

class PushNotification: NSObject {

    override init() {
        super.init()

        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
        }

        // Firebase Cloud Message
        Messaging.messaging().delegate = self
    }

    func requestAuthorization(_ completion: ((Bool) -> Void)? = nil) {
        if #available(iOS 10.0, *) {
            // iOS 10
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { granted, error in
                if let error = error {
                    Log.debug(error.localizedDescription)
                    return
                }

                DispatchQueue.main.async(execute: {
                    if granted {
                        Log.debug("通知 許可")
                        center.delegate = self
                        UIApplication.shared.registerForRemoteNotifications()
                    } else {
                        Log.debug("通知 拒否")
                    }
                    completion?(granted)
                })
            })
        } else {
            // iOS 9
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
            completion?(false)
        }
    }

    // 通知受信後の処理
    func handlePushNotification(_ userInfo: [AnyHashable: Any], isBackground: Bool = false) {
        print("handlePushNotification")
        guard let linkHostURL = self.linkHost(userInfo) else { return }
        Log.debug("linkHostURL : \(linkHostURL)")
    }

    // 通知のリンクを解析
    //  data: {
    //      push_link: 'firenze://massage', // などでPush通知受信後の処理
    //  },
    func linkHost(_ userInfo: [AnyHashable: Any]) -> URL? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil}
        // リンクをチェックしリダイレクト
        guard let pushLink = userInfo["push_link"] as? String else { return nil }
        guard let url = URL(string: pushLink) else { return nil }
        guard let scheme = url.scheme else { return nil }
        if scheme == "p-chat" || scheme == "http" || scheme == "https" {
            Log.debug("push_link : \(url)")
            return url
        }
        return nil
    }

    // 通知のタイトルを解析
    func linkTitle(_ userInfo: [AnyHashable: Any]) -> String? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        guard let title = userInfo["push_title"] as? String else { return nil }
        Log.debug("push_title : \(title)")
        return title
    }
}

@available(iOS 10.0, *)
extension PushNotification: UNUserNotificationCenterDelegate {

    // フォアグラウンドで通知受信
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {

        let userInfo = notification.request.content.userInfo

        // Print full message.
        Log.debug("\(notification.request.content.userInfo)")

        completionHandler([.alert, .sound])
        self.handlePushNotification(userInfo)
    }

    // リモート通知の開封時に発火
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {

        let userInfo = response.notification.request.content.userInfo
        self.handlePushNotification(userInfo)
        // 通知内のURLによって処理を分ける
        // self.linkHost(userInfo), self.linkTitle(userInfo)
    }
}

extension PushNotification: MessagingDelegate {
    // FireBase側で通知送信に必要な端末識別子を取得 Firestoreに保存する必要あり
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        Log.debug("Firebase registration token: \(fcmToken)")
        AccountData.fcmToken = fcmToken
        UserService.setLastLogin()
    }

    // Firebase Cloud Message で送信した通知を受信した際の処理 おそらく使わない
    func applicationReceivedRemoteMessage(received remoteMessage: MessagingRemoteMessage) {
        Log.debug("\(remoteMessage.appData)")
    }
}
