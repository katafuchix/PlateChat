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
                self.profileImageButton.sd_setBackgroundImage(with: URL(string:url), for: .normal) { [weak self] (image, error, cacheType, url) in
                    if error != nil {
                        self?.profileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
                    }
                }
            } else {
                self.profileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
            }
            self.profileTextLabel.text = AccountData.profile_text
        } else {
            if let toNickName = UsersData.nickNames[uid] {
                self.nicknameLabel.text = toNickName
                if let profile_image_url = UsersData.profileImages[uid] {
                    self.profileImageButton.sd_setBackgroundImage(with: URL(string:profile_image_url), for: .normal) { [weak self] (image, error, cacheType, url) in
                        if error != nil {
                            self?.profileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
                        }
                    }
                }
            } else {
                UserService.getUserInfo(uid, completionHandler: { [weak self] (user, error) in
                    if let user = user {
                        var dict = UsersData.profileImages
                        dict[user.key] = user.profile_image_url
                        UsersData.profileImages = dict

                        dict = UsersData.nickNames
                        dict[user.key] = user.nickname
                        UsersData.nickNames = dict

                        self?.nicknameLabel.text = user.nickname
                        self?.profileImageButton.sd_setBackgroundImage(with: URL(string:user.profile_image_url), for: .normal) { (image, error, cacheType, url) in

                            if error != nil {
                                self?.profileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
                            }
                        }
                    }
                })
            }
        }

        if self.profileTextLabel.text != "" {
            self.profileTextLabel.borderColor = UIColor.hexStr(hexStr: "#7DD8C7", alpha: 0.6)
            self.profileTextLabel.borderWidth = 1.0
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
