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

    fileprivate var dotBadges: [DotBadgeView] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.tabBar.tintColor = UIColor.hexStr(hexStr: "#40e0d0", alpha: 1.0)
        self.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBar.clipsToBounds = true
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 各タブにバッヂを配置 この時点ではhidden 通知が来たら表示する
        if dotBadges.count == 0 {
            addDotBadge(tabBar.subviews)
        }
    }

    // 各タブに点灯するだけの小さいバッジアイコンをadd
    fileprivate func addDotBadge(_ subviews: [UIView]) {
        tabBar.items?.forEach {
            guard let view = $0.value(forKey: "view") as? UIView else { return }
            let dot = DotBadgeView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
            view.addSubview(dot)
            dotBadges.append(dot)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
