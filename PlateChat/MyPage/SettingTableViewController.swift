//
//  SettingTableViewController.swift
//  PlateChat
//
//  Created by cano on 2018/08/04.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Rswift

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var notificationSwitch: UISwitch!

    @IBOutlet weak var replyNotificationSwitch: UISwitch!
    @IBOutlet weak var messageNotificationSwitch: UISwitch!
    @IBOutlet weak var footprintNotificationSwitch: UISwitch!
    
    @IBOutlet weak var passcodeSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorInset   = .zero
        self.tableView.tableFooterView  = UIView()
        
        self.bind()
    }

    func bind(){
        closeButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)

        if let boolr = AccountData.notification_reply {
            replyNotificationSwitch.isOn = boolr
        }
        replyNotificationSwitch.rx.value.asDriver()
            .skip(1)
            .drive(onNext: {
                UserService.setNotification("notification_reply", $0)
            }).disposed(by: rx.disposeBag)

        if let boolm = AccountData.notification_message {
            messageNotificationSwitch.isOn = boolm
        }
        messageNotificationSwitch.rx.value.asDriver()
            .skip(1)
            .drive(onNext: {
                 UserService.setNotification("notification_message", $0)
            }).disposed(by: rx.disposeBag)

        if let boolf = AccountData.notification_footprint {
            footprintNotificationSwitch.isOn = boolf
        }
        footprintNotificationSwitch.rx.value.asDriver()
            .skip(1)
            .drive(onNext: {
                 UserService.setNotification("notification_footprint", $0)
            }).disposed(by: rx.disposeBag)
        /*
         if let bool = AccountData.notification_on {
         notificationSwitch.isOn = bool
         }
        notificationSwitch.rx.value.asDriver()
            .skip(1)
            .drive(onNext: {
                UserService.setNotificationON($0)
            }).disposed(by: rx.disposeBag)
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        print(indexPath)

        switch indexPath.row {
        case 1:
            let vc = R.storyboard.profile.profileEditTableViewController()!
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = R.storyboard.blockList.blockListViewController()!
            self.navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = R.storyboard.account.accountTableViewController()!
            self.navigationController?.pushViewController(vc, animated: true)
        case 7:
            let vc = R.storyboard.rule.ruleViewController()!
            self.navigationController?.pushViewController(vc, animated: true)
        case 8:
            let vc = R.storyboard.privacy.privacyViewController()!
            self.navigationController?.pushViewController(vc, animated: true)
        case 9:
            let vc = R.storyboard.faq.faqViewController()!
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }

    /*
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
