//
//  SearchViewController.swift
//  PlateChat
//
//  Created by cano on 2018/09/15.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import SVProgressHUD

class SearchViewController: UIViewController {

    var userService: UserService?
    var users = [LoginUser]()
    var users_org = [LoginUser]()
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.userService = UserService()
        self.observeUser()
    }

    func observeUser() {
        SVProgressHUD.show(withStatus: "Loading...")
        self.userService?.bindUser(callbackHandler: { [weak self] (models, error) in
            SVProgressHUD.dismiss()
            switch error {
            case .none:
                if let models = models {
                    let preMessageCount = self?.users.count
                    self?.users_org = models + (self?.users_org)!
                    self?.users_org = (self?.users_org.unique { $0.key == $1.key }.sorted(by: { $0.created_date > $1.created_date}))!
                    self?.filterBlock()
                    if preMessageCount == self?.users.count {  // 更新数チェック
                        return
                    }
                    print(self?.users)
                    DispatchQueue.main.async {
                        //self?.tableView.reloadData()
                    }
                }
            case .some(.error(let error)):
                Log.error(error!)
            case .some(.noExistsError):
                Log.error("データ見つかりません")
            }
        })
    }

    func filterBlock() {
        let blockUsers = Array(UsersData.userBlock.filter {$0.1 == true}.keys)
        let blockedUsers = Array(UsersData.userBlocked.filter {$0.1 == true}.keys)
        self.users = self.users_org
            .filter { !blockUsers.contains( $0.key ) }
            .filter { !blockedUsers.contains(  $0.key ) }
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
