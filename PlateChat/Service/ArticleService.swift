//
//  ArticleService.swift
//  PlateChat
//
//  Created by cano on 2018/08/17.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

struct ArticleService {

    private init() { }
    private static let store   = Firestore.firestore()
    private static let storage = Storage.storage()

    static func createArticle(_ text: String, completionHandler: @escaping (_ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let data = [
            "uid"               : uid,
            "text"              : text,
            "status"            : 1,
            "created_date"   : FieldValue.serverTimestamp()
        ] as [String : Any]
        self.store.collection("artcle").addDocument(data:data, completion: { error in
            if let err = error {
                print("Error adding document: \(err)")
                completionHandler(err)
                return
            }
            completionHandler(nil)
        })
    }
}
