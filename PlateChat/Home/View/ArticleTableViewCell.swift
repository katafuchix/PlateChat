//
//  ArticleTableViewCell.swift
//  PlateChat
//
//  Created by cano on 2018/08/18.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit

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
        let text = article.text.trimmingCharacters(in: .whitespaces).uppercased().trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        self.articleLabel.text = text

        toButtonHeightConstraint.constant = 0.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
