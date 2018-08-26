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
    private static let articleLimit = 200
    public static let fcmTokenName = "fcmToken"
    
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
                            "created_at"        : FieldValue.serverTimestamp()
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
                        self.setUserInfo(user)

                        // 投稿更新
                        let query = self.store.collection("article")
                            .whereField("uid", isEqualTo: uid)
                            .whereField("status", isEqualTo: 1)
                            .order(by: "created_at", descending: true)
                            .limit(to: self.articleLimit)
                        query.addSnapshotListener(includeMetadataChanges: true) { (querySnapshot, error) in
                            do {
                                if let snapshot = querySnapshot {
                                    let articles = try snapshot.documents.compactMap { try Article(from: $0) }
                                    for article in articles {
                                        var data: [String: Any] = [:]
                                        if article.user_nickname != AccountData.nickname {
                                            data["user_nickname"] = AccountData.nickname
                                        }
                                        if article.user_prefecture_id != AccountData.prefecture_id {
                                            data["user_prefecture_id"] = AccountData.prefecture_id
                                        }
                                        if article.user_sex != AccountData.sex {
                                            data["user_sex"] = AccountData.sex
                                        }
                                        if article.user_pforile_image_url != AccountData.my_profile_image {
                                            data["user_pforile_image_url"] = AccountData.my_profile_image
                                        }
                                        if data.count == 0 { continue }

                                        self.store.collection("article").document(article.key).setData(data, merge: true,  completion: { _ in })
                                    }
                                }
                            } catch {}
                        }

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

    static func setUserInfo(_ user: LoginUser) {
        AccountData.nickname            = user.nickname
        AccountData.sex                 = user.sex
        AccountData.prefecture_id       = user.prefecture_id
        AccountData.profile_text        = user.profile_text
        AccountData.login_email         = user.login_email
        AccountData.login_password      = user.login_password
        AccountData.my_profile_image    = user.profile_image_url
    }

    static func clearUserInfo() {
        AccountData.nickname            = ""
        AccountData.sex                 = 0
        AccountData.prefecture_id       = 0
        AccountData.profile_text        = ""
        AccountData.login_email         = ""
        AccountData.login_password      = ""
        AccountData.my_profile_image    = ""
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

                        AccountData.my_profile_image = avatarURL.absoluteString
                        // 投稿更新
                        let query = self.store.collection("article")
                            .whereField("uid", isEqualTo: uid)
                            .whereField("status", isEqualTo: 1)
                            .order(by: "created_at", descending: true)
                            .limit(to: self.articleLimit)
                        query.addSnapshotListener(includeMetadataChanges: true) { (querySnapshot, error) in
                            do {
                                if let snapshot = querySnapshot {
                                    let articles = try snapshot.documents.compactMap { try Article(from: $0) }
                                    for article in articles {
                                        var data: [String: Any] = [:]
                                        if article.user_pforile_image_url != AccountData.my_profile_image {
                                            data["user_pforile_image_url"] = AccountData.my_profile_image
                                        }
                                        if data.count == 0 { continue }
                                        self.store.collection("article").document(article.key).setData(data, merge: true,  completion: { _ in })
                                    }
                                }
                            } catch {}
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
        var data = [
                    "last_login_date"   : FieldValue.serverTimestamp(),
                    "devise"            : UserDeviceInfo.getDeviceInfo()
            ] as [String : Any]
        if AccountData.fcmToken != nil {
            data["fcmToken"] = AccountData.fcmToken 
        }
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
                        self.setUserInfo(user)
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

    // 別ユーザーでログイン
    static func changeLoginUser(_ login_email: String, _ login_password: String, completionHandler: @escaping (_ user: LoginUser?, _ error: UserServiceFetchError?) -> Void) {

        let query = self.store.collection("login_user")
        .whereField("login_email", isEqualTo: login_email)
        .whereField("login_password", isEqualTo: login_password)
        .whereField("status", isEqualTo: 1)
        
        query.addSnapshotListener({(querySnapshot, error) in
            if let _ = error {
                completionHandler(nil, .noExistsError)
                return
            }

            guard let snapshot = querySnapshot else {
                completionHandler(nil, .noExistsError)
                return
            }

            if snapshot.documents.count == 0 {
                completionHandler(nil, .noExistsError)
                return
            }
            do {
                let login_user = try LoginUser(from: snapshot.documents[0])
                //try Auth.auth().signOut()
                Auth.auth().signIn(withEmail: login_user.email, password: login_user.password, completion: { (user, error) in
                    if error != nil {
                        Log.error(error!)
                        completionHandler(nil, .noExistsError)
                        return
                    }
                    self.clearUserInfo()
                    self.setUserInfo(login_user)
                    completionHandler(login_user, nil)
                })
            } catch {
                completionHandler(nil, .noExistsError)
            }
        })
    }

    static func logout() throws {
        do {
            try Auth.auth().signOut()
        } catch {

        }
    }

    // ユーザー情報取得
    static func getUserInfo(_ uid: String, completionHandler: @escaping (_ user: LoginUser?, _ error: UserServiceFetchError?) -> Void) {
        guard (Auth.auth().currentUser?.uid) != nil else { return }

        let profileDocumentRef = self.store.document("login_user/\(uid)")

        profileDocumentRef.getDocument { (document, error) in
            if error != nil {
                completionHandler(nil, .fetchError(error))
            } else if let document = document, document.exists {
                do {
                    let user = try LoginUser(from: document)
                    completionHandler(user, nil)

                } catch {
                    // TODO: Errorバリエーション定義
                    completionHandler(nil, .fetchError(error))
                }
            } else {
                completionHandler(nil, .noExistsError)
            }
        }
    }

}
