//
//  ViewController+Extended.swift
//  PlateChat
//
//  Created by cano on 2018/08/13.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import SVProgressHUD

private let indicatorViewTag = 100928

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

    func showIndicatorView() {
        guard let indicatorView = R.nib.indicatorView.firstView(owner: nil) else { fatalError() }
        indicatorView.frame = view.bounds
        indicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        indicatorView.translatesAutoresizingMaskIntoConstraints = true
        indicatorView.tag = indicatorViewTag
        view.addSubview(indicatorView)
        view.bringSubview(toFront: indicatorView)
    }

    func hideIndicatorView() {
        if let indicatorView = view.viewWithTag(indicatorViewTag) {
            // TODO: トランジション追加
            indicatorView.removeFromSuperview()
        }
    }

    func showLoading(_ message: String? = nil) {
        //SVProgressHUD.setMinimumSize(CGSize(width: 200, height: 200))
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: message ?? "Loading...")
    }

    func hideLoading() {
        SVProgressHUD.dismiss()
    }
}
