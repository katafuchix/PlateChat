//
//  UserService.swift
//  PlateChat
//
//  Created by cano on 2018/08/07.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

enum UserServiceFetchError: Error {
    case fetchError(Error?)
    case noExistsError
}

enum UserServiceUpdateError: Error {
    case updateError(Error?)
}

struct UserService {

    enum UserAvatarAction {
        case save(URL)
        case delete
    }

    enum ImageAvatarAction {
        case save(UIImage)
        case delete
    }

    private init() { }
    private static let store   = Firestore.firestore()
    private static let storage = Storage.storage()

    // ユーザー登録
    // 先にAuthの方でユーザーを作って　そのuidをキーとしてlogin_userでデータを生成
    static func createUser(completionHandler: @escaping (_ uid: String?, _ error: UserServiceFetchError?) -> Void) {
        let email       = UtilManager.getNowDateString() + "_" + UtilManager.generateString() + "@deskplate.net"
        let password    = "test1234"
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error ?? "Not Trackable Error")
                return
            }

            if let user = user?.user {
                let uid = user.uid
                print("uid")
                print(uid)
                let data = [
                            "email" : email,
                            "password" : password,
                            "status": 1,
                            "last_login_date": FieldValue.serverTimestamp()
                ] as [String : Any]
                self.store.collection("login_user").document(uid).setData(data, completion: { error in
                    if let err = error {
                        print("Error adding document: \(err)")
                        return
                    }
                    completionHandler(uid, nil)
                })
            }
        })
    }

    // 最終ログイン
    static func setLastLogin() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let data = ["last_login_date": FieldValue.serverTimestamp()] as [String : Any]
        self.store.collection("login_user").document(uid).setData(data, merge: true, completion: { error in
            if let err = error {
                print("Error adding document: \(err)")
                return
            }
        })
    }
}
