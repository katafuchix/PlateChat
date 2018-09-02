//
//  NoticeViewController.swift
//  PlateChat
//
//  Created by cano on 2018/09/02.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit

class NoticeViewController: UIViewController {

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
    }


    private struct PagingMenuOptions: PagingMenuControllerCustomizable {
        let pv1 = R.storyboard.footPrint.footPrintViewController()!
        let pv2 = R.storyboard.footPrint.footPrintViewController()!
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
                return UIColor.gray
            }
            */
            var focusMode: MenuFocusMode {
                return .roundRect(radius: 12, horizontalPadding: 8, verticalPadding: 8, selectedColor: UIColor.lightGray)
                //return .roundRect(radius:  16, horizontalPadding: 8, verticalPadding: 8, selectedColor: UIColor.lightGray)
            }
            var itemsOptions: [MenuItemViewCustomizable] {
                return [MenuItem1(), MenuItem2()]//, MenuItem3()]
            }
        }

        fileprivate struct MenuItem1: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                //return .text(title: MenuItemText(text: "赤い画面", color: UIColor.red, selectedColor: UIColor.white))
                let title = MenuItemText(text: "Menu1")
                return .text(title: title)
            }
        }

        fileprivate struct MenuItem2: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                //return .text(title: MenuItemText(text: "青い画面", color: UIColor.blue, selectedColor: UIColor.white))
                let title = MenuItemText(text: "Menu2")
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
