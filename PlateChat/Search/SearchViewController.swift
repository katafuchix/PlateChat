//
//  SearchViewController.swift
//  PlateChat
//
//  Created by cano on 2018/09/15.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import SVProgressHUD
import Rswift

class SearchViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var userService: UserService?
    var users = [LoginUser]()
    var users_org = [LoginUser]()
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.collectionView.register(R.nib.searchWideCell)
        self.collectionView.collectionViewLayout = self.flowLayout()
        self.collectionView.alwaysBounceVertical = true

        self.userService = UserService()
        self.observeUser()
    }

    private func flowLayout() -> UICollectionViewFlowLayout {
        let flow = UICollectionViewFlowLayout()

        let inset: CGFloat = 4.0
        //let width = view.bounds.width / 2 - inset * 2
        flow.sectionInset = UIEdgeInsetsMake(0, inset, 0, inset)
        flow.minimumLineSpacing = 10
        flow.minimumInteritemSpacing = 10
        //flow.itemSize = CGSize(width: width, height: 250)

        return flow
    }

    func observeUser() {
        SVProgressHUD.show(withStatus: "Loading...")
        self.userService?.bindUser(callbackHandler: { [weak self] (models, error) in
            SVProgressHUD.dismiss()
            switch error {
            case .none:
                if let models = models {
                    let preMessageCount = self?.users.count
                    self?.users_org = models + (self?.users_org)!
                    self?.users_org = (self?.users_org.unique { $0.key == $1.key }.sorted(by: { $0.created_date > $1.created_date}))!
                    self?.filterBlock()
                    if preMessageCount == self?.users.count {  // 更新数チェック
                        return
                    }
                    print(self?.users)
                    DispatchQueue.main.async {
                        //self?.tableView.reloadData()
                        self?.collectionView.reloadData()
                    }
                }
            case .some(.error(let error)):
                Log.error(error!)
            case .some(.noExistsError):
                Log.error("データ見つかりません")
            }
        })
    }

    func filterBlock() {
        let blockUsers = Array(UsersData.userBlock.filter {$0.1 == true}.keys)
        let blockedUsers = Array(UsersData.userBlocked.filter {$0.1 == true}.keys)
        self.users = self.users_org
            .filter { !blockUsers.contains( $0.key ) }
            .filter { !blockedUsers.contains(  $0.key ) }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
// MARK: - UICollectionViewDelegateFlowLayout

extension SearchViewController : UICollectionViewDelegateFlowLayout {
/*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.pager.elements.count == 0 { return CGSize.zero }
        if self.pager.isPagingCompleted && self.pager.elements.count > 0 { return CGSize.zero }
        // リフレッシュ判定
        if !self.collectionView.isUserInteractionEnabled { return CGSize.zero }

        // 1ページ目には出さない
        if self.pager.elements.count <= 8 { return CGSize.zero }

        return CGSize(width: collectionView.frame.size.width, height: PageLoadingView.defaultHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = (view.bounds.width - SearchCell.defaultSize.width * 2) / 3
        return UIEdgeInsetsMake(0, inset, 0, inset)
    }
*/
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: 250, height: 250)//SearchCell.defaultSize
    }
}

// MARK: - UICollectionViewDataSource

extension SearchViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("self.users.count")
        print(self.users.count)
        return self.users.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        /*
        let cell = collectionView.dequeueCell(SearchCell.self, indexPath: indexPath)
        cell.backgroundColor = UIColor.clear
        let data = self.pager.elements[indexPath.row]
        cell.configureData(data)
*/
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.searchWideCell, for: indexPath)!
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension SearchViewController : UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //collectionView.deselectItem(at: indexPath, animated: true)

        print(indexPath)
    }
}
