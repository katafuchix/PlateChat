//
//  UIImageView+WebImage.swift
//  matching
//
//  Created by xxxAIRINxxx on 2017/02/08.
//  Copyright © 2017 NOWALL, Inc. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

extension UIImageView {
    
    func loadWebImage(_ urlString: String?, _ placeholderImage: UIImage? = nil, completion: ((UIImage?) -> Void)? = nil) {
        self.loadWebImageWithAnimation(urlString, placeholderImage) { image in
            completion?(image)
        }
    }
    
    func loadWebImageWithAnimation(_ urlString: String?, _ placeholderImage: UIImage? = nil, completion: ((UIImage?) -> Void)?) {
        self.loadWebImageWithURL(urlString, placeholderImage) { [weak self]  image, error, cacheType, url in
            guard let _self = self else { return }
            
            if cacheType == .none {
                UIView.transition(with: _self,
                                  duration: 0.2,
                                  options: [.transitionCrossDissolve, .allowUserInteraction], animations: {}) { finished in
                                    completion?(image)
                }
            } else {
                completion?(image)
            }
        }
    }

    func loadWebImageWithURL(_ urlString: String?, _ placeholderImage: UIImage? = nil , _ completion:
        //SDWebImageCompletionBlock?) {
        SDExternalCompletionBlock?) {
        self.cancelImageLoad()
        guard let _urlString = urlString, !_urlString.isEmpty else {
            if let _placeholderImage = placeholderImage { self.image = _placeholderImage }
            return
        }
        
        self.sd_setImage(with: URL(string: _urlString),
                         placeholderImage: placeholderImage,
                         options: .retryFailed,
                         completed: nil)//completion)
    }

    func cancelImageLoad() {
        self.sd_cancelCurrentImageLoad()
        self.sd_cancelCurrentAnimationImagesLoad()
    }
}
