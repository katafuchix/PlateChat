//
//  ProfileCell.swift
//  PlateChat
//
//  Created by cano on 2018/09/07.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileCell: UITableViewCell {

    @IBOutlet weak var profileImageButton: CircleButton!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var profileAttrLabel: UILabel!
    @IBOutlet weak var profileTextLabel: PaddingLabel!

    var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(_ uid: String) {
        self.clear()

        if uid == AccountData.uid {
            self.nicknameLabel.text = AccountData.nickname
            
            if let url = AccountData.my_profile_image {
                self.profileImageButton.sd_setBackgroundImage(with: URL(string:url), for: .normal) { (image, error, cacheType, url) in
                }
            } else {
                self.profileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
            }
            self.profileTextLabel.text = AccountData.profile_text
        }
    }

    func clear() {
        self.profileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
        self.nicknameLabel.text = ""
        self.profileAttrLabel.text = ""
        self.profileTextLabel.text = ""
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
