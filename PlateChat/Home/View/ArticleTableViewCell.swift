//
//  ArticleTableViewCell.swift
//  PlateChat
//
//  Created by cano on 2018/08/18.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import SDWebImage
import RxSwift
import RxCocoa
import NSObject_Rx
import Firebase

class ArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfileImageButton: CircleButton!
    @IBOutlet weak var userNicknameLabel: UILabel!
    @IBOutlet weak var userAttrLabel: UILabel!


    @IBOutlet weak var toButtonBaseView: UIView!
    @IBOutlet weak var toButtonBaseViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var toButton: UIButton!

    @IBOutlet weak var articleLabel: UILabel!

    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var talkButton: UIButton!
    @IBOutlet weak var buttonBaseView: UIView!
    @IBOutlet weak var buttonBaseViewHeight: NSLayoutConstraint!

    var article: Article?
    var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(_ article: Article) {
        self.clear()

        self.article = article

        if article.user_pforile_image_url.description.count > 0 {
            self.userProfileImageButton.sd_setBackgroundImage(with: URL(string:article.user_pforile_image_url), for: .normal) { (image, error, cacheType, url) in
            }
        }
        self.userNicknameLabel.text = article.user_nickname
        let text = article.text.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .whitespacesAndNewlines)
        self.articleLabel.text = text

        //print(Constants.prefs.filter {$0.0 == article.user_prefecture_id }.map { $0.1 }[0])
        //print(Constants.genders[article.user_sex])
        if Auth.auth().currentUser?.uid == article.uid {
            self.buttonBaseViewHeight.constant = 0.0
            self.buttonBaseView.isHidden = true
        } else {
            self.buttonBaseViewHeight.constant = 34.0
            self.buttonBaseView.isHidden = false
        }
        self.talkButton.isEnabled = true

        self.toButtonBaseViewHeightConstraint.constant = 0.0
        self.toButtonBaseView.isHidden = true
    }

    func clear() {
        self.article = nil
        self.userProfileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
        self.userNicknameLabel.text = ""
        self.userAttrLabel.text = ""
        self.articleLabel.text = ""
        self.buttonBaseViewHeight.constant = 30.0
        self.buttonBaseView.isHidden = false
        self.talkButton.isEnabled = false
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
