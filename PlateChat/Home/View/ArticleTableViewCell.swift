//
//  ArticleTableViewCell.swift
//  PlateChat
//
//  Created by cano on 2018/08/18.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var articleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(_ article: Article) {
        self.articleLabel.text = article.text
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
