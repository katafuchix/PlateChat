//
//  AccountData.swift
//  PlateChat
//
//  Created by cano on 2018/08/12.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit

struct AccountData {

    private enum DataType: String {
        case login = "login"
        case userId = "user_id"
        case deviceToken = "device_token"
        case authToken = "auth_token"
        case email = "email"
        case password = "password"
        case isShowedThanksAlert = "isShowedThanksAlert"
        case sex = "sex"
        case confirmed = "confirmed"
        case mainImageRole = "main_image_role" // 0:常に公開 / 1:いいねした相手にのみ / 2:マッチングした相手のみ / 3: 常に非公開
        case lastForegroundDate = "lastForegroundDate"
        case unsendReceipts = "unsendReceipts"
        case unconfirmedMobilePhone = "unconfirmedMobilePhone"
        case no_charging_member = "no_charging_member"              // 無料会員:true
        case normal_charging_member = "normal_charging_member"      // 有料会員:true
        case premium_charging_member = "premium_charging_member"    // プレミアム会員:true
        case age_confirmed_at = "profile.age_confirmed_at"  // 年齢認証
        case age_certification_status = "age_certification_status"  // 年齢認証の進捗  accepted / pending / default
        case facebookProfilePicture = "facebook_profile_picture"    // Facebookのユーザー画像。FB経由での登録時に使用
    }

    private init() {}

    private static let ud = UserDefaults.standard
    
}
