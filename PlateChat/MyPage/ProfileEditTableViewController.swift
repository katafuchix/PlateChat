//
//  ProfileEditTableViewController.swift
//  PlateChat
//
//  Created by cano on 2018/08/06.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import RxSwift
import RxCocoa
import NSObject_Rx
import SVProgressHUD
import SDWebImage

class ProfileEditTableViewController: UITableViewController {

    private let store   = Firestore.firestore()
    private let storage = Storage.storage()

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var profileImageButton: CircleButton!
    @IBOutlet weak var nicknameTextField: UITextField!

    @IBOutlet weak var manButton: CircleSexButton!
    @IBOutlet weak var womanButton: CircleSexButton!
    @IBOutlet weak var noneButton: CircleSexButton!

    let viewModel = ProfileEditViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tableView.allowsSelection  = false
        self.tableView.separatorInset   = .zero
        self.tableView.tableFooterView  = UIView()

        // 性別
        //self.noneButton.isSelected = true
        setUserData()
        bind()
    }

    func setUserData() {
        self.nicknameTextField.text = AccountData.nickname
        switch AccountData.sex {
        case 0:
            self.buttonSelect(self.noneButton)
        case 1:
            self.buttonSelect(self.manButton)
        case 2:
            self.buttonSelect(self.womanButton)
        default:
            break
        }
        if let url = AccountData.my_profile_image {
            self.profileImageButton.sd_setBackgroundImage(with: URL(string:url), for: .normal) { [weak self] (image, error, cacheType, url) in
            }
        } else {
            self.profileImageButton.setBackgroundImage(UIImage(named: "person-icon"), for: .normal)
        }
    }

    func bind() {
        // ニックネーム
        self.nicknameTextField.rx.text.orEmpty.bind(to: self.viewModel.nickName).disposed(by: rx.disposeBag)

        // 性別
        self.manButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.buttonSelect((self?.manButton)!)
        }).disposed(by: rx.disposeBag)

        self.womanButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.buttonSelect((self?.womanButton)!)
        }).disposed(by: rx.disposeBag)

        self.noneButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.buttonSelect((self?.noneButton)!)
        }).disposed(by: rx.disposeBag)

        // 保存
        saveButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            let dic = [
                "nickname" : self?.viewModel.nickName.value ?? "",
                "sex" : self?.viewModel.sex.value ?? 0
                ] as [String : Any]
            print(dic)
            SVProgressHUD.show(withStatus: "Updating...")
            UserService.updateLoginUser(dic,completionHandler: { ( user, error) in
                                            SVProgressHUD.dismiss()
                                            guard let user = user else { return }
                                            if error != nil {
                                                self?.showAlert("Error!")
                                                return
                                            } else {
                                                AccountData.nickname = user.nickname
                                                AccountData.sex      = user.sex
                                                self?.showAlert("更新しました")
                                            }
            })
        }).disposed(by: rx.disposeBag)

        // 画像
        profileImageButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.showUploadActionSheet()
        }).disposed(by: rx.disposeBag)
    }

    // 性別
    func buttonSelect(_ button: CircleSexButton) {
        if button.isSelected { return }
        self.manButton.isSelected   = false
        self.womanButton.isSelected = false
        self.noneButton.isSelected  = false
        button.isSelected = true
        self.viewModel.sex.value = button.tag
    }

    func uploadImage(_ image: UIImage) {
        SVProgressHUD.show(withStatus: "Uploading...")
        UserService.uploadProfileImage(image, completionHandler: { [weak self] (urlStr, error) in
            SVProgressHUD.dismiss()
            guard let urlStr = urlStr else { return }
            if error != nil {
                self?.showAlert("Error!")
                return
            } else {
                AccountData.my_profile_image = urlStr
                self?.profileImageButton.sd_setBackgroundImage(with: URL(string:urlStr), for: .normal)
                self?.showAlert("プロフィール画像を登録しました")
            }
        })
    }

    func showUploadActionSheet() {
        // styleをActionSheetに設定
        let actionSheet = UIAlertController(title: "アバター設定", message: "選択してください。", preferredStyle: UIAlertControllerStyle.actionSheet)

        // 選択肢を生成
        let cameraAction = UIAlertAction(
            title: "写真を撮る",
            style: .default,
            handler: { [weak self] _ in
                // カメラが利用可能か
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    // 写真を選ぶビュー
                    let pickerView = UIImagePickerController()
                    // 写真の選択元をカメラにする
                    pickerView.sourceType = .camera
                    // トリミング機能ON
                    pickerView.allowsEditing = true
                    // デリゲート
                    pickerView.delegate = self
                    // ビューに表示
                    self?.present(pickerView, animated: true)
                }
        })

        let selectedAlbumAtion = UIAlertAction(
            title: "写真を選択",
            style: .default,
            handler: { [weak self] _ in
                // カメラロールが利用可能か
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    // 写真を選ぶビュー
                    let pickerView = UIImagePickerController()
                    // 写真の選択元をカメラロールにする
                    pickerView.sourceType = .photoLibrary
                    // トリミング機能ON
                    pickerView.allowsEditing = true
                    // デリゲート
                    pickerView.delegate = self
                    // ビューに表示
                    self?.present(pickerView, animated: true)
                }
        })

        let deleteAction = UIAlertAction(
            title: "写真を削除",
            style: .default,
            handler: { [weak self] _ in
                // デフォルト画像に差し替え
                //self?.avatarImageView.image = nil
                //self?.setHiddenAvatarImageView(true)
                //self?.avatarSettings = .removed

                //self?.updateButtons()
        })

        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)

        // アクションを追加
        if UIImagePickerController.isSourceTypeAvailable(.camera) { actionSheet.addAction(cameraAction) }
        actionSheet.addAction(selectedAlbumAtion)
        //if addButtonImageView.isHidden { actionSheet.addAction(deleteAction) }
        actionSheet.addAction(cancelAction)
        actionSheet.popoverPresentationController?.sourceView = view
        present(actionSheet, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ProfileEditTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // 写真が選択された時に呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        print("avatar ")
        let avatar = info[UIImagePickerControllerEditedImage] as? UIImage
        //self.profileImageButton.setImage(avatar, for: .normal)
        if let image = avatar {
            self.uploadImage(image)
        }
        // 前の画面に戻る
        dismiss(animated: true, completion: nil)
    }
}
