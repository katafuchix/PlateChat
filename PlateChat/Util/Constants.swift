//
//  Constants.swift
//  PlateChat
//
//  Created by cano on 2018/08/05.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation

struct Constants {
    /// 開発版モード
    /// - Budle ID: 開発版
    /// - API接続先: 開発環境
    ///
    static var DEBUG: Bool {
        #if DEBUG || PAYMENT
        // DEBUG、PAYMENTが定義されていたら開発モード
        return true
        #else
        return false
        #endif
    }

    /// 課金試験モード
    /// - Budle ID: 製品版
    /// - API接続先: 開発環境
    ///
    static var PAYMENT: Bool {
        #if PAYMENT
        // PAYMENTが定義済みの場合のみ、課金試験モード
        return true
        #else
        return false
        #endif
    }

    /// 製品版モード
    /// - Budle ID: 製品版
    /// - API接続先: 本番環境
    ///
    static var PRODUCTION: Bool {
        #if PRODUCTION
        // PRODUCTIONが定義済みの場合のみ製品版モード
        return true
        #else
        return false
        #endif
    }

    /**
     GoogleService-Info.plist path
     */
    static var GoogleServiceInfoPlistPath: String {
        if Constants.DEBUG {
            return Bundle.main.path(forResource: "GoogleService-Info-dev", ofType: "plist")!
        } else {
            return Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!
        }
    }
}
