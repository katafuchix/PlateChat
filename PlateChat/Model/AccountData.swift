//
//  AccountData.swift
//  PlateChat
//
//  Created by cano on 2018/08/12.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import Firebase

struct AccountData {

    private enum DataType: String {
        case uid            = "uid"         // Auth.auth().currentUser?.uid
        case nickname       = "nickname"
        case email          = "email"
        case password       = "password"
        case login_email    = "login_email"
        case login_password = "login_password"
        case sex            = "sex"
        case prefecture_id  = "prefecture_id"
        case profile_text   = "profile_text"
        case my_profile_image = "my_profile_image" // メイン画像
        case fcmToken       = "fcmToken" // firebase remote notification token
        case notification_on = "notification_on" // 通知設定
    }

    private init() {}

    private static let ud = UserDefaults.standard

    static var uid: String? {
        get { return Auth.auth().currentUser?.uid }
    }

    static var nickname: String? {
        get { return self.ud.string(forKey: AccountData.DataType.nickname.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.nickname.rawValue); self.ud.synchronize() }
    }

    static var login_email: String? {
        get { return self.ud.string(forKey: AccountData.DataType.login_email.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.login_email.rawValue); self.ud.synchronize() }
    }

    static var login_password: String? {
        get { return self.ud.string(forKey: AccountData.DataType.login_password.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.login_password.rawValue); self.ud.synchronize() }
    }

    static var sex: Int {
        get { return self.ud.integer(forKey: AccountData.DataType.sex.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.sex.rawValue); self.ud.synchronize() }
    }

    static var prefecture_id: Int {
        get { return self.ud.integer(forKey: AccountData.DataType.prefecture_id.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.prefecture_id.rawValue); self.ud.synchronize() }
    }

    static var profile_text: String? {
        get { return self.ud.string(forKey: AccountData.DataType.profile_text.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.profile_text.rawValue); self.ud.synchronize() }
    }

    // メイン画像
    static var my_profile_image: String? {
        get { return self.ud.string(forKey: AccountData.DataType.my_profile_image.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.my_profile_image.rawValue); self.ud.synchronize() }
    }

    static var fcmToken: String? {
        get { return self.ud.string(forKey: AccountData.DataType.fcmToken.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.fcmToken.rawValue); self.ud.synchronize() }
    }

    static var notification_on: Bool? {
        get { return self.ud.bool(forKey: AccountData.DataType.notification_on.rawValue) }
        set { self.ud.set(newValue, forKey: AccountData.DataType.notification_on.rawValue); self.ud.synchronize() }
    }
}
