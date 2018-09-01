//
//  UsersData.swift
//  PlateChat
//
//  Created by cano on 2018/08/31.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import Firebase

struct UsersData {

    private enum DataType: String {
        case profileImages  = "profileImages"
        case nickNames      = "nickNames"
        case userBlock      = "userBlock"
        case userBlocked    = "userBlocked"
    }

    private init() {}

    private static let ud = UserDefaults.standard

    static var profileImages: [String: String] {
        get { return self.ud.object(forKey: UsersData.DataType.profileImages.rawValue) as? [String: String] ?? [String: String]()}
        set { self.ud.set(newValue, forKey: UsersData.DataType.profileImages.rawValue); self.ud.synchronize() }
    }

    static var nickNames: [String: String] {
        get { return self.ud.object(forKey: UsersData.DataType.nickNames.rawValue) as? [String: String] ?? [String: String]()}
        set { self.ud.set(newValue, forKey: UsersData.DataType.nickNames.rawValue); self.ud.synchronize() }
    }

    static var userBlock: [String: Bool] {
        get { return self.ud.object(forKey: UsersData.DataType.userBlock.rawValue) as? [String: Bool] ?? [String: Bool]()}
        set { self.ud.set(newValue, forKey: UsersData.DataType.userBlock.rawValue); self.ud.synchronize() }
    }

    static var userBlocked: [String: Bool] {
        get { return self.ud.object(forKey: UsersData.DataType.userBlocked.rawValue) as? [String: Bool] ?? [String: Bool]()}
        set { self.ud.set(newValue, forKey: UsersData.DataType.userBlocked.rawValue); self.ud.synchronize() }
    }
}
