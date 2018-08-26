//
//  ChatRoomService.swift
//  PlateChat
//
//  Created by cano on 2018/08/26.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

enum ChatRoomBindStatus: String {
    case loading
    case done
    case failed
    case none
}

enum ChatRoomBindError: Error {
    case error(Error?)
    case noExistsError
}

enum ChatRoomServiceUpdateError: Error {
    case updateError(Error?)
}

enum PostChatRoomError: Error {
    case error(Error?)
}

class ChatRoomService {

    private let store   = Firestore.firestore()
    private let storage = Storage.storage()
    private var bindArticleHandler: ListenerRegistration?
    private let limit = 100          // １ページあたりの表示数 仮の値


    // 作成
    func cerateChatRoom (_ other_uid: String, _ completionHandler: @escaping (_ chatRoom: ChatRoom?, _ error: ChatRoomServiceUpdateError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if uid == other_uid { return }

        let query = self.store.collection("chat_room")
            .whereField("members.\(uid)", isEqualTo: true)
            .whereField("members.\(other_uid)", isEqualTo: true)
            .whereField("status", isEqualTo: 1)
            //.order(by: "created_at", descending: true)

        query.addSnapshotListener(includeMetadataChanges: false) { (querySnapshot, error) in
        //query.getDocuments() { (querySnapshot, error) in // 何故か作成後に動かない
            do {
                if let snapshot = querySnapshot {
                    if snapshot.count == 0 {
                        var data = [String: Any]()
                        data["owner"]       = uid
                        data["members"]     = [uid: true, other_uid: true]
                        data["created_at"]  = FieldValue.serverTimestamp()
                        data["status"]      = 1

                        self.store.collection("chat_room").addDocument(data:data, completion: {
                            error in
                            if let err = error {
                                print("Error adding document: \(err)")
                                completionHandler(nil, .updateError(error))
                                return
                            }

                            query.getDocuments() { (docSnapshot, error) in
                                if let err = error {
                                    print("Error adding document: \(err)")
                                    completionHandler(nil, .updateError(error))
                                    return
                                }
                                if let snapshot = querySnapshot, snapshot.count > 0 {
                                do{
                                    let chatRoom = try snapshot.documents.compactMap{ try ChatRoom(from: $0) }
                                    completionHandler(chatRoom[0],nil)
                                } catch {}
                                    completionHandler(nil,nil)
                                }
                            }
                        })
                    } else {
                        do{
                            let chatRoom = try snapshot.documents.compactMap{ try ChatRoom(from: $0) }
                            completionHandler(chatRoom[0],nil)
                        } catch {}
                    }
                }
            }
            if let _ = error {
                completionHandler(nil, .updateError(error))
            }
        }
    }
}
