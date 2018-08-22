//
//  ArticleTableViewCell.swift
//  PlateChat
//
//  Created by cano on 2018/08/18.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import SDWebImage

class ArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfileImageButton: CircleButton!
    @IBOutlet weak var userNicknameLabel: UILabel!
    @IBOutlet weak var userAttrLabel: UILabel!

    @IBOutlet weak var articleLabel: UILabel!

    @IBOutlet weak var toButton: UIButton!
    @IBOutlet weak var toButtonHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(_ article: Article) {
        self.clear()

        if article.user_pforile_image_url.description.count > 0 {
            self.userProfileImageButton.sd_setBackgroundImage(with: URL(string:article.user_pforile_image_url), for: .normal) { (image, error, cacheType, url) in
            }
        }
        self.userNicknameLabel.text = article.user_nickname
        let text = article.text.trimmingCharacters(in: .whitespaces).uppercased().trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        self.articleLabel.text = text

        //print(Constants.prefs.filter {$0.0 == article.user_prefecture_id }.map { $0.1 }[0])
        //print(Constants.genders[article.user_sex])
    }

    func clear() {
        self.userProfileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
        self.userNicknameLabel.text = ""
        self.userAttrLabel.text = ""
        self.articleLabel.text = ""
        //toButtonHeightConstraint.constant = 0.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
