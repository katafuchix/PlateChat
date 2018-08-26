//
//  ChatMessageService.swift
//  PlateChat
//
//  Created by cano on 2018/08/26.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import Firebase

enum ChatMessageBindError: Error {
    case error(Error?)
    case noExistsError
}

enum PostChatMessageError: Error {
    case error(Error?)
}

enum ChatMessageBindStatus: String {
    case loading
    case done
    case failed
    case none
}

class ChatMessageService {
    private let store   = Firestore.firestore()
    private var bindTalkHandler: ListenerRegistration?
    private let chatRoom: ChatRoom
    private let limit = 20          // １ページあたりの表示数 仮の値
    private var lastChatMessageDocument: QueryDocumentSnapshot? // クエリカーソルの開始点
    private var status: ChatMessageBindStatus
    private let compressibility: CGFloat = 0.9   // jpeg圧縮率

    init(_ chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        self.lastChatMessageDocument = nil
        self.status = .none
    }

    func bindChatMessage(callbackHandler: @escaping ([ChatMessage]?, ChatMessageBindError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let chatRoomKey: String = self.chatRoom.key else { return }

        if self.status == .loading { return }
        self.status = .loading

        let query: Query
        if let lastDocument = self.lastChatMessageDocument {
            query = self.store
                .collection("/chat_room/\(chatRoomKey)/messages/")
                .order(by: "created_at", descending: true)
                .start(afterDocument: lastDocument)
                .limit(to: limit)
        } else {
            query = self.store
                .collection("/chat_room/\(chatRoomKey)/messages/")
                .order(by: "created_at", descending: true)
                .limit(to: limit)
        }

        bindTalkHandler = query.addSnapshotListener(includeMetadataChanges: true) { [weak self] (querySnapshot, error) in
            if let error = error {
                self?.status = .failed
                callbackHandler(nil, .error(error))
                return
            }

            guard let snapshot = querySnapshot else {
                self?.status = .failed
                callbackHandler(nil, .noExistsError)
                return
            }

            self?.lastChatMessageDocument = snapshot.documents.last
            do {
                let messages = try snapshot.documents.compactMap { try ChatMessage(from: $0) }.sorted(by: { $0.sentDate < $1.sentDate})
                self?.status = .done
                callbackHandler(messages, nil)
            } catch {
                self?.status = .failed
                callbackHandler(nil, .error(error))
            }
        }
    }

    func postChatMessage(text: String, callbackHandler: @escaping (PostChatMessageError?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let chatRoomKey: String = self.chatRoom.key else { return }

        let data: [String: Any] = [
            "sender"    : uid,
            "text"      : text,
            "created_at": FieldValue.serverTimestamp(),
            "status"    : 1
        ]
        self.store.collection("/chat_room/\(chatRoomKey)/messages/").addDocument(data: data) { error in
            if let error = error {
                callbackHandler(.error(error))
                return
            }
            callbackHandler(nil)
        }
    }
}
