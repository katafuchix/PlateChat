//
//  HomeViewController.swift
//  PlateChat
//
//  Created by cano on 2018/08/17.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Rswift
import NSObject_Rx
import SVProgressHUD

class HomeViewController: UIViewController {

    @IBOutlet weak var writeButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!

    var articleService: ArticleService?
    var articles = [Article]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.writeButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            let vc = R.storyboard.write.writeViewController()!
            vc.delegate = self
            UIWindow.createNewWindow(vc).open()
        }).disposed(by: rx.disposeBag)

        self.tableView.separatorInset   = .zero
        self.tableView.tableFooterView  = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.estimatedRowHeight = 170 // これはStoryBoardの設定で無視されるかも？
        tableView.rowHeight = UITableViewAutomaticDimension

        self.articleService = ArticleService()

        SVProgressHUD.show(withStatus: "Loading...")
        self.articleService?.bindTalk(callbackHandler: { [weak self] (models, error) in
            guard let weakSelf = self else { return }
            print("models")
            print(models)
            switch error {
            case .none:
                if let models = models {
                    let preMessageCount = weakSelf.articles.count
                    weakSelf.articles = models

                    /*
                    weakSelf.messages = Array([models, weakSelf.messages].joined()) // キャッシュのせいかたまに重複することがあるのでユニークにしておく
                    weakSelf.messages = weakSelf.messages.unique { $0.messageId == $1.messageId }.sorted(by: { $0.sentDate < $1.sentDate})

                    if preMessageCount == weakSelf.messages.count {  // 更新数チェック
                        weakSelf.refreshControl.endRefreshing()
                        return
                    }*/
                    DispatchQueue.main.async {
                        weakSelf.tableView.reloadData()
                        //callbackHandler()
                    }
                }
            case .some(.error(let error)):
                Log.error(error!)
            case .some(.noExistsError):
                Log.error("データ見つかりません")
            }
            //weakSelf.refreshControl.endRefreshing()
            SVProgressHUD.dismiss()
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension HomeViewController : UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCell(withIdentifier: String(describing: ArticleTableViewCell.self), for: indexPath) as! ArticleTableViewCell
        //cell.set(content: datasource[indexPath.row])
        cell.configure(self.articles[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        let content = datasource[indexPath.row]
        content.expanded = !content.expanded
        tableView.reloadRows(at: [indexPath], with: .automatic)
        */
    }
}

extension HomeViewController: writeVCprotocol {
    func close() {
        (UIApplication.shared.delegate as! AppDelegate).window?.close()
    }
}
