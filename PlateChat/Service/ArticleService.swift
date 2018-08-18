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

enum ArticleBindStatus: String {
    case loading
    case done
    case failed
    case none
}

enum ArticleBindError: Error {
    case error(Error?)
    case noExistsError
}

enum PostArticleError: Error {
    case error(Error?)
}

class ArticleService {

    private let store   = Firestore.firestore()
    private let storage = Storage.storage()
    private var bindArticleHandler: ListenerRegistration?
    private let limit = 10          // １ページあたりの表示数 仮の値
    private var lastArticleDocument: QueryDocumentSnapshot? // クエリカーソルの開始点
    private var status: ArticleBindStatus

    init() {
        self.status = .none
    }

    func bindTalk(callbackHandler: @escaping ([Article]?, ArticleBindError?) -> Void) {

        if self.status == .loading { return }
        self.status = .loading

        let query: Query
        if let lastDocument = self.lastArticleDocument {
            query = store
                .collection("/article/")
                .order(by: "created_at", descending: true)
                .start(afterDocument: lastDocument)
                .limit(to: limit)
        } else {
            query = store
                .collection("/article/")
                .order(by: "created_at", descending: true)
                .limit(to: limit)
        }

        bindArticleHandler = query.addSnapshotListener(includeMetadataChanges: true) { [weak self] (querySnapshot, error) in
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

            self?.lastArticleDocument = snapshot.documents.last
            do {
                let articles = try snapshot.documents.compactMap { try Article(from: $0) }.sorted(by: { $0.created_date < $1.created_date})
                self?.status = .done
                callbackHandler(articles, nil)
            } catch {
                self?.status = .failed
                callbackHandler(nil, .error(error))
            }
        }
    }

    // 投稿
    func createArticle(_ text: String, completionHandler: @escaping (_ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let data = [
            "uid"               : uid,
            "text"              : text,
            "status"            : 1,
            "created_at"        : FieldValue.serverTimestamp(),
            "user_pforile_image_url"  : AccountData.my_profile_image ?? "",
            "user_prefecture_id"      : AccountData.prefecture_id,
            "user_sex"                : AccountData.sex,
            "user_nickname"           : AccountData.nickname ?? ""
        ] as [String : Any]
        self.store.collection("article").addDocument(data:data, completion: { error in
            if let err = error {
                print("Error adding document: \(err)")
                completionHandler(err)
                return
            }
            completionHandler(nil)
        })
    }
}
