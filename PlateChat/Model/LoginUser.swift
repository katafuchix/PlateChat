//
//  LoginUser.swift
//  PlateChat
//
//  Created by cano on 2018/08/07.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import Firebase

struct LoginUser {

    enum ModelError: Error {
        case parseError
    }
    
    let key: String
    let email: String
    let password: String
    let login_email: String
    let login_password: String
    let nickname: String
    let sex: Int
    let status: Int


    init(from document: DocumentSnapshot) throws {
        key = document.documentID

        guard
            let email   = document.get("email") as? String,
            let pass    = document.get("password") as? String,
            let status  = document.get("status") as? Int
            else { throw ModelError.parseError }

        self.email          = email
        self.password       = pass
        self.status         = status
        self.login_email    = (document.get("login_email") as? String) ?? ""
        self.login_password = (document.get("login_password") as? String) ?? ""
        self.nickname       = (document.get("nickname") as? String) ?? ""
        self.sex            = (document.get("sex") as? Int) ?? 0
    }
}
