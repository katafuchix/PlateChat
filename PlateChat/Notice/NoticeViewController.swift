//
//  NoticeViewController.swift
//  PlateChat
//
//  Created by cano on 2018/09/02.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Rswift

class NoticeViewController: UIViewController {

    @IBOutlet weak var refreshButton: UIBarButtonItem!

    static let pv1 = R.storyboard.footPrint.footPrintViewController()!
    static let pv2 = R.storyboard.articleReplyLog.articleReplyLogViewController()!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // PagingMenuController追加
        let options = PagingMenuOptions()
        let pagingMenuController = PagingMenuController(options: options)

        // 高さ調整。この2行を追加
        pagingMenuController.view.frame.origin.y += 64
        pagingMenuController.view.frame.size.height -= 64

        self.addChildViewController(pagingMenuController)
        self.view.addSubview(pagingMenuController.view)
        pagingMenuController.didMove(toParentViewController: self)

        self.refreshButton.rx.tap.subscribe(onNext: { [unowned self] in
            NoticeViewController.pv1.observeFootprint()
            NoticeViewController.pv2.observeArticleReplyLog()
        }).disposed(by: rx.disposeBag)
    }


    private struct PagingMenuOptions: PagingMenuControllerCustomizable {
        let pv1 = NoticeViewController.pv1
        let pv2 = NoticeViewController.pv2
        let pv3 = R.storyboard.footPrint.footPrintViewController()!

        fileprivate var componentType: ComponentType {
            //return .all(menuOptions: MenuOptions(), pagingControllers: pagingControllers)
            return .all(menuOptions: MenuOptions(), pagingControllers: [pv1, pv2])
        }

        fileprivate var pagingControllers: [UIViewController] {
            return [pv1, pv2]
        }

        fileprivate struct MenuOptions: MenuViewCustomizable {
            var displayMode: MenuDisplayMode {
                //return .infinite(widthMode: .flexible, scrollingMode: MenuScrollingMode.pagingEnabled)
                return .segmentedControl
            }
            var height: CGFloat {
                return 44
            }
/*
            var backgroundColor: UIColor {
                return UIColor.lightGray
            }
            var selectedBackgroundColor: UIColor {
                return UIColor.white
            }
*/
            var focusMode: MenuFocusMode {
                return .roundRect(radius: 12, horizontalPadding: 8, verticalPadding: 8, selectedColor: UIColor.hexStr(hexStr: "#7DD8C7", alpha: 0.6))
                //return .roundRect(radius:  16, horizontalPadding: 8, verticalPadding: 8, selectedColor: UIColor.lightGray)
            }
            var itemsOptions: [MenuItemViewCustomizable] {
                return [MenuItem1(), MenuItem2()]//, MenuItem3()]
            }
        }

        fileprivate struct MenuItem1: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                //return .text(title: MenuItemText(text: "赤い画面", color: UIColor.red, selectedColor: UIColor.white))
                let title = MenuItemText(text: "足あと", color: UIColor.lightGray, selectedColor: UIColor.white)
                return .text(title: title)
            }
        }

        fileprivate struct MenuItem2: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                //return .text(title: MenuItemText(text: "青い画面", color: UIColor.blue, selectedColor: UIColor.white))
                let title = MenuItemText(text: "返信", color: UIColor.lightGray, selectedColor: UIColor.white)
                return .text(title: title)
            }
        }

        fileprivate struct MenuItem3: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                return .text(title: MenuItemText(text: "黄色い画面", color: UIColor.yellow, selectedColor: UIColor.white))
            }
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
