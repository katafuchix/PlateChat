//
//  UserDetailViewController.swift
//  PlateChat
//
//  Created by cano on 2018/09/23.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Rswift
import SVProgressHUD
import SKPhotoBrowser

class UserDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var articleService: ArticleService?
    var articles = [Article]()
    var uid: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.bind()
    }

    func bind() {
        self.tableView.register(R.nib.articleTableViewCell)
        self.tableView.register(R.nib.profileCell)
        self.tableView.register(R.nib.talkButtonTableViewCell)
        self.tableView.separatorInset   = .zero
        self.tableView.tableFooterView  = UIView()
        //tableView.estimatedRowHeight = 170 // これはStoryBoardの設定で無視されるかも？
        tableView.rowHeight = UITableViewAutomaticDimension

        self.articleService = ArticleService()
        self.articleService?.lastUidArticle = nil
        self.observeArticle()
        // ページング
        tableView.rx.willDisplayCell.subscribe(onNext: { [unowned self] (cell, indexPath) in
            if indexPath.section == 1 && self.isEndOfSections(indexPath) {
                self.observeArticle()
            }
        }).disposed(by: rx.disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        self.observeArticle()
    }

    func observeArticle() {
        SVProgressHUD.show(withStatus: "Loading...")
        self.articleService?.bindUidArticle(self.uid!, callbackHandler: { [weak self] (models, error) in
            SVProgressHUD.dismiss()
            switch error {
            case .none:
                if let models = models {
                    let preMessageCount = self?.articles.count
                    self?.articles = models + (self?.articles)!
                    self?.articles = (self?.articles.unique { $0.key == $1.key }.sorted(by: { $0.created_date > $1.created_date}))!
                    if preMessageCount == self?.articles.count {  // 更新数チェック
                        return
                    }
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            case .some(.error(let error)):
                Log.error(error!)
            case .some(.noExistsError):
                Log.error("データ見つかりません")
            }
        })
    }

    /// セクション配列・セクション内の末尾位置か調べる
    /// - return: Bool (true -> End of Sections and Rows)
    func isEndOfSections(_ indexPath: IndexPath) -> Bool {
        return indexPath.row == self.articles.lastIndex
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UserDetailViewController : UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return articles.count
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView .dequeueReusableCell(withIdentifier: String(describing: ArticleTableViewCell.self), for: indexPath) as! ArticleTableViewCell
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.profileCell, for: indexPath)!
            cell.configure(self.uid!)
            cell.profileImageButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
                if let image = cell.profileImageButton.backgroundImage(for: .normal) , let image_url = AccountData.my_profile_image {
                    // SKPhotoBrowserを利用して別ウィンドウで開く
                    var images = [SKPhoto]()
                    let photo = SKPhoto.photoWithImage(image)
                    images.append(photo)
                    let browser = SKPhotoBrowser(photos: images)
                    browser.initializePageIndex(0)
                    self?.present(browser, animated: true, completion: {})
                }
            }).disposed(by: cell.disposeBag)

            cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.width, bottom: 0, right: 0)
            return cell

        case 1:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.talkButtonTableViewCell, for: indexPath)!
            if self.uid == AccountData.uid {
                cell.talkButton.isEnabled = false
                cell.talkButton.backgroundColor = UIColor.lightGray
            }
            cell.talkButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
                SVProgressHUD.show(withStatus: "Loading...")

                let chatRoomService = ChatRoomService()

                let vc = ChatMessageViewController()
                // ChatRoom 取得 なければ作成
                if let uid = self?.uid {
                    chatRoomService.cerateChatRoom(uid, { [weak self] (chatroom, error) in
                        SVProgressHUD.dismiss()
                        if let err = error {
                            self?.showAlert(err.localizedDescription)
                            return
                        }
                        guard let chatRoom = chatroom else { return }
                        // snapshotでコールバックが複数回実行されるのを回避
                        let bool = self?.navigationController?.topViewController is ChatMessageViewController
                        if !bool {
                            vc.chatRoom     = chatRoom
                            vc.other_uid    = uid
                            vc.hidesBottomBarWhenPushed = true
                            self?.navigationController?.pushViewController(vc, animated: true)
                        }
                    })
                }
            }).disposed(by: cell.disposeBag)
            
            return cell

        default:

        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articleTableViewCell, for: indexPath)!
        //cell.set(content: datasource[indexPath.row])
        cell.configure(self.articles[indexPath.row])

        /*rx.tap.subscribe(onNext: { _ in
         print("ボタンを押しました！")
         }).disposed(by: rx.disposeBag)*/

        cell.talkButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            SVProgressHUD.show(withStatus: "Loading...")

            let chatRoomService = ChatRoomService()

            let vc = ChatMessageViewController()
            if let article = cell.article {
                // ChatRoom 取得 なければ作成
                chatRoomService.cerateChatRoom(article.uid, { [weak self] (chatroom, error) in
                    SVProgressHUD.dismiss()
                    if let err = error {
                        self?.showAlert(err.localizedDescription)
                        return
                    }
                    guard let chatRoom = chatroom else { return }

                    // snapshotでコールバックが複数回実行されるのを回避
                    let bool = self?.navigationController?.topViewController is ChatMessageViewController
                    if !bool {
                        vc.chatRoom     = chatRoom
                        vc.other_uid    = article.uid
                        vc.hidesBottomBarWhenPushed = true
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                })
            }
        }).disposed(by: cell.disposeBag)

        cell.replyButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            let vc = R.storyboard.write.writeViewController()!
            vc.delegate = self
            vc.article = self?.articles[indexPath.row]
            UIWindow.createNewWindow(vc).open()
        }).disposed(by: cell.disposeBag)

        return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension UserDetailViewController: writeVCprotocol {
    func close() {
        (UIApplication.shared.delegate as! AppDelegate).window?.close()
    }
}

