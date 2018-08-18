//
//  Article.swift
//  PlateChat
//
//  Created by cano on 2018/08/18.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import Firebase

class Article: NSObject {

    enum ModelError: Error {
        case parseError
    }

    let key: String
    let uid: String
    let text: String
    let created_date: Date
    let status: Int

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
    }
}
