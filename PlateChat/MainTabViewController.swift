//
//  MainTabViewController.swift
//  PlateChat
//
//  Created by cano on 2018/08/04.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SVProgressHUD
import Firebase

class MainTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.tabBar.tintColor = .orange
        //NVActivityIndicatorView.show(message: "loading...")
        SVProgressHUD.setDefaultStyle(.dark)
        
        print("Auth.auth().currentUser?.uid")
        print(Auth.auth().currentUser?.uid)
        print(Auth.auth().currentUser?.email)
        print(UserDeviceInfo.getDeviceInfo())

        if Auth.auth().currentUser?.uid == nil {
            UserService.createUser(completionHandler: { (uid, _) in print(" create \(String(describing: uid))") })
        }
        UserService.setLastLogin()
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
