//
//  Article.swift
//  PlateChat
//
//  Created by cano on 2018/08/18.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import Firebase

class Article {

    let key: String
    let uid: String
    let text: String
    let created_date: Date
    let status: Int

    let user_nickname: String
    let user_pforile_image_url: String
    let user_prefecture_id: Int
    let user_sex: Int


    init(from document: DocumentSnapshot) throws {
        key = document.documentID

        guard
            let uid   = document.get("uid") as? String,
            let text    = document.get("text") as? String,
            let status  = document.get("status") as? Int
            else { throw ModelError.parseError }
        self.uid            = uid
        self.text           = text
        self.status         = status
        self.created_date   = (document.get("created_at") as? Timestamp)?.dateValue() ?? Date()

        self.user_nickname  = (document.get("user_nickname") as? String) ?? ""
        self.user_pforile_image_url = (document.get("user_pforile_image_url") as? String) ?? ""
        self.user_prefecture_id = (document.get("user_prefecture_id") as? Int) ?? 0
        self.user_sex = (document.get("user_sex") as? Int) ?? 0
    }
}
