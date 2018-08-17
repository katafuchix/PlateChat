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
    case fetchError(Error?)
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
                            "email"             : email,
                            "password"          : password,
                            "devise"            : UserDeviceInfo.getDeviceInfo(),
                            "prefecture_id"     : 0,
                            "status"            : 1,
                            "last_login_date"   : FieldValue.serverTimestamp(),
                            "created_date"      : FieldValue.serverTimestamp()
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

    // プロフィール設定
    static func updateLoginUser(_ dic: [String: Any], completionHandler: @escaping (_ user: LoginUser?, _ error: UserServiceUpdateError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let data = dic
        self.store.collection("login_user").document(uid).setData(data, merge: true, completion: { error in
            if error != nil {
                completionHandler(nil, .updateError(error))
                return
            }
            // 最新情報を取得
            let profileDocumentRef = self.store.collection("login_user").document(uid)
            profileDocumentRef.getDocument { (document, error) in
                if error != nil {
                    completionHandler(nil, .fetchError(error))
                } else if let document = document, document.exists {
                    do {
                        let user = try LoginUser(from: document)

                        AccountData.nickname        = user.nickname
                        AccountData.sex             = user.sex
                        AccountData.prefecture_id   = user.prefecture_id
                        AccountData.profile_text    = user.profile_text
                        completionHandler(user, nil)
                    } catch {
                        completionHandler(nil, .fetchError(error))
                    }
                } else {
                    completionHandler(nil, .fetchError(error))
                }
            }
        })
    }

    // プロフィール画像
    static func uploadProfileImage(_ image: UIImage, completionHandler: @escaping (_ urlStr: String?, _ error: UserServiceUpdateError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if let jpeg = UIImageJPEGRepresentation(image, 0.9) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let avatarStoragePath = Storage.storage().reference().child("ProfilePhoto/\(uid)/avatar.jpg")

            avatarStoragePath.putData(jpeg, metadata: metadata) { _, error in
                if nil != error {
                    completionHandler(nil, .updateError(error))
                    return
                }
                avatarStoragePath.downloadURL(completion: { url, error in
                    //print("storage image url")
                    //print(url)
                    guard let avatarURL = url else {
                        completionHandler(nil, .updateError(error))
                        return
                    }
                    // urlを保存
                    let data = [
                            "profile_image_url"             : avatarURL.absoluteString
                        ] as [String : String]
                    self.store.collection("login_user").document(uid).setData(data, merge: true,  completion: { error in
                        if let err = error {
                            completionHandler(nil, .updateError(err))
                            return
                        }
                        completionHandler(avatarURL.absoluteString, nil)
                    })
                })
            }
        }
    }
    // 最終ログイン
    static func setLastLogin() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let data = [
                    "last_login_date"   : FieldValue.serverTimestamp(),
                    "devise"            : UserDeviceInfo.getDeviceInfo()
            ] as [String : Any]
        self.store.collection("login_user").document(uid).setData(data, merge: true, completion: { error in
            if let err = error {
                print("Error adding document: \(err)")
                return
            }
            // 最新情報を取得
            let profileDocumentRef = self.store.collection("login_user").document(uid)
            profileDocumentRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    do {
                        let user = try LoginUser(from: document)
                        AccountData.nickname        = user.nickname
                        AccountData.sex             = user.sex
                        AccountData.prefecture_id   = user.prefecture_id
                        AccountData.profile_text    = user.profile_text
                    } catch {}
                }
            }
        })
    }

    // 通知設定
    static func setNotificationON(_ bool: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let data = ["notification_on": bool] as [String : Bool]
        self.store.collection("login_user").document(uid).setData(data, merge: true, completion: { error in
            if let err = error {
                print("Error adding document: \(err)")
                return
            }
        })
    }
}
