//
//  SearchWindowViewController.swift
//  PlateChat
//
//  Created by cano on 2018/09/22.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import SVProgressHUD
import SwiftRangeSlider

protocol searchWindowVCprotocol {
    func close()
}

class SearchWindowViewController: UIViewController {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var rangeSlider: RangeSlider!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var manButton: CircleSexButton!
    @IBOutlet weak var womanButton: CircleSexButton!
    @IBOutlet weak var noneButton: CircleSexButton!
    @IBOutlet weak var prefTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!

    var delegate: searchWindowVCprotocol?
    var pickerView: UIPickerView = UIPickerView()
    let prefs: Variable<[Int: String]> = Variable([:])
    let prefNameArray: Variable<[String]> = Variable([])

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUserData()
        self.bind()
    }

    func setUserData() {
        if UserSearchData.ageLower < 18 {
            UserSearchData.ageLower = 18
        }
        if UserSearchData.ageUpper == 0 {
            UserSearchData.ageUpper = 99
        }
        self.showAge()

        switch UserSearchData.sex {
        case 0:
            self.buttonSelect(self.noneButton)
        case 1:
            self.buttonSelect(self.manButton)
        case 2:
            self.buttonSelect(self.womanButton)
        default:
            break
        }
    }

    func bind() {
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

        self.closeButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.delegate?.close()
        }).disposed(by: rx.disposeBag)

        // 年齢
        self.rangeSlider.minimumValue = 18
        self.rangeSlider.maximumValue = 99
        self.rangeSlider.lowerValue = Double(UserSearchData.ageLower)
        self.rangeSlider.upperValue = Double(UserSearchData.ageUpper)
        self.rangeSlider.rx.controlEvent(UIControlEvents.valueChanged).asDriver().drive(onNext: { [weak self] value in
            UserSearchData.ageLower = Int(round(self?.rangeSlider.lowerValue ?? 18.0))
            UserSearchData.ageUpper = Int(round(self?.rangeSlider.upperValue ?? 99.0))
            self?.showAge()
        }).disposed(by: rx.disposeBag)

        // 住所
        self.prefTextField.setInputAccessoryView()
        self.prefTextField.inputView = pickerView
        pickerView.showsSelectionIndicator = true
        self.prefNameArray.value = Constants.prefs.sorted(by: {$0.0 < $1.0}).map { $0.1 }
        self.prefNameArray.value[0] = "指定しない"
        pickerView.selectRow(UserSearchData.prefecture_id, inComponent: 0, animated: false)
        self.prefTextField.text = self.prefNameArray.value[UserSearchData.prefecture_id]

        self.prefNameArray.asObservable().bind(to: pickerView.rx.itemTitles) {_, item in
            return "\(item)"
            }.disposed(by: rx.disposeBag)

        pickerView.rx.itemSelected.subscribe { [weak self] (event) in
            switch event {
            case .next(let selected):
                self?.prefTextField.text = self?.prefNameArray.value[selected.row]
                UserSearchData.prefecture_id = selected.row
            default:
                break
            }
        }.disposed(by: rx.disposeBag)

        self.searchButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.delegate?.close()
        }).disposed(by: rx.disposeBag)
    }

    func showAge() {
        self.ageLabel.text = "\(UserSearchData.ageLower)歳 〜 \(UserSearchData.ageUpper)歳"
    }

    // 性別
    func buttonSelect(_ button: CircleSexButton) {
        if button.isSelected { return }
        self.manButton.isSelected   = false
        self.womanButton.isSelected = false
        self.noneButton.isSelected  = false
        button.isSelected = true
        UserSearchData.sex = button.tag
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
