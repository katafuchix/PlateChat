//
//  WriteViewController.swift
//  PlateChat
//
//  Created by cano on 2018/08/17.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import SVProgressHUD

protocol writeVCprotocol {
    func close()
}

class WriteViewController: UIViewController {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!

    var delegate: writeVCprotocol?
    let articleService = ArticleService()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.textView.becomeFirstResponder()
        self.textView.rx.didChange.subscribe(onNext: { [weak self] _ in
            self?.placeholderLabel.isHidden = true
        }).disposed(by: rx.disposeBag)
        //self.textView.becomeFirstResponder()

        self.closeButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.delegate?.close()
        }).disposed(by: rx.disposeBag)

        self.postButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            guard let text = self?.textView.text else { return }
            if text.description.count > 100 {
                Alert.init("自己紹介は100文字以内で入力してください").show(self)
                return
            }

            self?.postButton.isEnabled = false
            SVProgressHUD.show(withStatus: "Posting...")
            self?.articleService.createArticle(text, completionHandler: { _ in
                SVProgressHUD.dismiss()
                self?.delegate?.close()
            })
        }).disposed(by: rx.disposeBag)

        self.textView.rx.text.orEmpty.asDriver().drive(onNext:{ [weak self] str in
            self?.countLabel.text = "\(String(describing: str.description.count))/200"
            self?.postButton.isEnabled = str.description.count >= 10 && str.description.count <= 200
        }).disposed(by: rx.disposeBag)

        let tapGesture = UITapGestureRecognizer()
        self.view.addGestureRecognizer(tapGesture)
        tapGesture.rx.event.bind(onNext: { [weak self] recognizer in
            self?.delegate?.close()
        }).disposed(by: rx.disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
