//
//  Array+Extended.swift
//  PlateChat
//
//  Created by cano on 2018/08/26.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import Foundation

extension Array {
    // 配列から重複する要素を除く
    func unique(predicate: @escaping (Element, Element) -> Bool) -> [Element] {
        var result: [Element] = []
        forEach { elm -> Void in
            guard !result.contains(where: { res -> Bool in
                return predicate(res, elm)
            }) else { return }
            result.append(elm)
        }
        return result
    }
}

