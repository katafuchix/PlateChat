//
//  ChatMessage.swift
//  PlateChat
//
//  Created by cano on 2018/08/07.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation
import FirebaseAuth
import MessageKit

class ChatMessage: NSObject, MessageType {

    @objc var fromId: String?
    @objc var text: String?
    @objc var timeStamp: NSNumber?
    @objc var toId: String?
    @objc var imageUrl: String?
    @objc var imageWidth: NSNumber?
    @objc var imageHeight: NSNumber?
    @objc var videoUrl: String?


    // MessageKit MessageType variables
    var messageId: String
    var sender: Sender
    var sentDate: Date
    var kind: MessageKind
    // MessageKit MessageType variables
    
    init(kind: MessageKind, sender: Sender, messageId: String, date: Date) {
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }

    func chatPartnerId() -> String {
        return (fromId == Auth.auth().currentUser?.uid ? toId : fromId)!
    }
}
