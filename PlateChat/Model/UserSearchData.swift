//
//  UserSearchData.swift
//  PlateChat
//
//  Created by cano on 2018/09/22.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit

struct UserSearchData {

    private enum DataType: String {
        case ageLower       = "ageLower"
        case ageUpper       = "ageUpper"
        case sex            = "sex"
        case prefecture_id  = "prefecture_id"
    }

    private init() {}

    private static let ud = UserDefaults.standard

    static var ageLower: Int {
        get { return self.ud.integer(forKey: UserSearchData.DataType.ageLower.rawValue) }
        set { self.ud.set(newValue, forKey: UserSearchData.DataType.ageLower.rawValue); self.ud.synchronize() }
    }

    static var ageUpper: Int {
        get { return self.ud.integer(forKey: UserSearchData.DataType.ageUpper.rawValue) }
        set { self.ud.set(newValue, forKey: UserSearchData.DataType.ageUpper.rawValue); self.ud.synchronize() }
    }

    static var sex: Int {
        get { return self.ud.integer(forKey: UserSearchData.DataType.sex.rawValue) }
        set { self.ud.set(newValue, forKey: UserSearchData.DataType.sex.rawValue); self.ud.synchronize() }
    }

    static var prefecture_id: Int {
        get { return self.ud.integer(forKey: UserSearchData.DataType.prefecture_id.rawValue) }
        set { self.ud.set(newValue, forKey: UserSearchData.DataType.prefecture_id.rawValue); self.ud.synchronize() }
    }

}
