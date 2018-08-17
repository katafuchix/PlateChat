//
//  ViewController+Extended.swift
//  PlateChat
//
//  Created by cano on 2018/08/13.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit

extension UIViewController {

    func showAlert(_ title: String, _ message: String? = nil, _ buttonTitle: String? = nil, completion: AlertCompletion? = nil) {
        let alert = Alert(title, message)
        _ = alert.addAction(buttonTitle ?? "OK", completion: completion)
        alert.show(self)
    }

    func showAlertOKCancel(
        _ title: String, _ message: String? = nil, _ buttonTitle: String? = nil, _ cancelbuttonTitle: String? = nil, completion: AlertCompletion? = nil

        ){
        let alert = Alert(title, message)
        _ = alert.addAction(buttonTitle ?? "OK", completion: completion)
        _ = alert.setCancelAction(cancelbuttonTitle ?? "Cancel", completion: nil)
        alert.show(self)
    }
}
