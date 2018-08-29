//
//  ChatRoomListViewController.swift
//  PlateChat
//
//  Created by cano on 2018/08/30.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit

class ChatRoomListViewController: UIViewController {

    var chatRoomService: ChatRoomService?
    var chatRooms = [ChatRoom]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.chatRoomService = ChatRoomService()
        self.chatRoomService?.bindChatRoom(callbackHandler: { [weak self] (models, error) in
            print(models)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
