//
//  ChatRoom.swift
//  PlateChat
//
//  Created by cano on 2018/08/26.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import Firebase

class ChatRoom: WithFirestoreData {

    var key: String!
    let owner: String
    let members: [String: Bool]
    let status: Int

    init(from: ChatRoom) {
        self.key        = from.key
        self.owner      = from.owner
        self.members    = from.members
        self.status     = from.status
    }
}

extension ChatRoom: Equatable {
    static func == (lhs: ChatRoom, rhs: ChatRoom) -> Bool {
        return lhs.key == rhs.key &&
            lhs.members == rhs.members
    }
}

