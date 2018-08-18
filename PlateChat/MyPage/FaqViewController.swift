//
//  FaqViewController.swift
//  PlateChat
//
//  Created by cano on 2018/08/18.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class FaqViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    var datasource = [FaqTableViewCellContent]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // 戻るボタン
        self.backButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)

        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.separatorInset   = .zero
        self.tableView.tableFooterView  = UIView()
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableViewAutomaticDimension

        datasource = [FaqTableViewCellContent(title: "機種変更後にアカウントの引き継ぎはできますか？ ",
                                                    subtitle: "　日本経済新聞社とテレビ東京による22～24日の世論調査で、安倍内閣の支持率は52％となり、前回の５月下旬の42％から10ポイント上昇した。不支持率は５月の53％から42％に下がった。支持率が不支持率を上回るのは２月以来、４カ月ぶり。"),
                      FaqTableViewCellContent(title: "「起業の都」再び　京都に集まる資金・人材 ",
                                                    subtitle: "京セラ、日本電産など個性的な企業を生み出した京都で、もう一つの顔・京都大学と企業の関係が変わってきた。従来は共同研究が中心だったが、小回りの利くスタートアップ企業を通じ「大学の知」をビジネスに生かす動きが本格化。多くのノーベル賞受賞者を輩出し、自然科学分野の基礎研究に定評がある京大を核として「起業の都」に新たな波が起きている。"),
                      FaqTableViewCellContent(title: "アマゾン、ＡＩスピーカーの“スキル”1000種に ",
                                                    subtitle: "米アマゾン・ドット・コムが投入した人工知能（ＡＩ）スピーカーの日本国内で使える独自機能が増え、スマートフォン（スマホ）のアプリに該当する「スキル」と呼ばれる機能がこのほど1000種類を突破した。スキルの技術仕様を外部に公開していることが、付加価値の高いスキルの開発につながっているようだ。")]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension FaqViewController : UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCell(withIdentifier: String(describing: FaqTableViewCell.self), for: indexPath) as! FaqTableViewCell
        cell.set(content: datasource[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let content = datasource[indexPath.row]
        content.expanded = !content.expanded
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
