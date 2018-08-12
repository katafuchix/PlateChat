//
//  NoticeViewController.swift
//  PlateChat
//
//  Created by cano on 2018/08/02.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
//import Pageboy
import RxSwift
//import Tabman

class NoticeViewController: UIViewController {

    let viewControllers = [ViewController(), ViewController()]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
/*
        // Setup Tabman
        dataSource = self
        bar.items = [            TabmanBar.Item(title: "お相手から"),
                                 TabmanBar.Item(title: "あなたから")
        ]
        bar.style = .blockTabBar//.buttonBar
        setTabmanBarAppearance()
 */
    }

    /*
    private func setTabmanBarAppearance() {

        bar.appearance = TabmanBar.Appearance({ appearance in
            appearance.state.selectedColor = UIColor.lightGray //R.clr.patersTheme.plainText()
            appearance.state.color = UIColor.black //R.clr.patersTheme.weakText()

            //appearance.text.font = R.font.notoSansCJKjpSubMedium(size: 14)

            appearance.style.background = .solid(color: .white)
            appearance.style.bottomSeparatorColor = UIColor.gray//R.clr.patersTheme.tableCellBorder()

            appearance.layout.height = .explicit(value: 60)
            appearance.layout.itemVerticalPadding = 8
            appearance.layout.edgeInset = 0
            appearance.layout.interItemSpacing = 0
            appearance.layout.edgeInset = 20
            //appearance.indicator.preferredStyle = .custom(type: LikeListTabIndicator.self)

            //appearance.bottomSeparator.height = .
            appearance.indicator.useRoundedCorners = true

            appearance.layout.extendBackgroundEdgeInsets = true
            appearance.interaction.isScrollEnabled = false
        })
    }
    */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - PageboyViewControllerDataSource
/*
extension NoticeViewController: PageboyViewControllerDataSource {

    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return 2
    }

    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return self.viewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }

}
*/
