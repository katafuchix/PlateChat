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

class ProfileEditTableViewController: UITableViewController {

    private let store   = Firestore.firestore()
    private let storage = Storage.storage()
    @IBOutlet weak var profileImageButton: CircleButton!
    @IBOutlet weak var nicknameTextField: UITextField!

    @IBOutlet weak var manButton: CircleButton!
    @IBOutlet weak var womanButton: CircleButton!
    @IBOutlet weak var onButton: CircleButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tableView.allowsSelection  = false
        self.tableView.separatorInset   = .zero
        self.tableView.tableFooterView  = UIView()

        manButton.borderColor = .gray

        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let profileDocumentRef = self.store.document("login_user/\(uid)")
        profileDocumentRef.getDocument { (document, error) in
            if error != nil {
                //completionHandler(nil, .fetchError(error))
            } else if let document = document, document.exists {
                do {
                    let user = try LoginUser(from: document)
                    print(user)
                    print(user.email)
                    print(user.status)
                    //completionHandler(user, nil)

                } catch {
                    // TODO: Errorバリエーション定義
                    //completionHandler(nil, .fetchError(error))
                }
            } else {
                //completionHandler(nil, .noExistsError)
            }
        }

        profileImageButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.showUploadActionSheet()
        }).disposed(by: rx.disposeBag)
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
        // 画像を置き換える
        //avatarImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        //setHiddenAvatarImageView(false)

        //avatarSettings = .changed
        //updateButtons()
        /*
         guard let avatar = info[UIImagePickerControllerEditedImage] as? UIImage else {
         return
         }
         */
        let avatar = info[UIImagePickerControllerEditedImage] as? UIImage
        if let image = avatar, let jpeg = UIImageJPEGRepresentation(image, 0.9), let uid = Auth.auth().currentUser?.uid {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"

            let avatarStoragePath = Storage.storage().reference().child("ProfilePhoto/\(uid)/avatar.jpg")

            avatarStoragePath.putData(jpeg, metadata: metadata) { _, error in
                if nil != error {
                    //completionHandler(nil, error)
                    return
                }
                avatarStoragePath.downloadURL(completion: { url, error in
                    print("storage image url")
                    print(url)
                    guard let avatarURL = url else {
                        //completionHandler(nil, error)

                        return
                    }
                    //completionHandler(avatarURL, nil)
                })
            }
        }

        // 前の画面に戻る
        dismiss(animated: true, completion: nil)
    }
}
