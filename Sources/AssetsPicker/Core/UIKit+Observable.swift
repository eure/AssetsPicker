//
//  UIKit+Observable.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/18.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import UIKit

private struct PropertyKey {
    static var uiLabel: Void
    static var isHidden: Void?
    static var uiImageView: Void?
    static var barButtonItemEnabled: Void?
    static var caLayerContent: Void?
}

extension UIView {
    var hiddenLink: Link<Bool> {
        if let link = objc_getAssociatedObject(self, &PropertyKey.isHidden) as? Link<Bool> {
            return link
        } else {
            let link = Link<Bool>() { [weak self] hidden in
                DispatchQueue.main.async {
                    self?.isHidden = hidden
                }
            }
            objc_setAssociatedObject(self, &PropertyKey.isHidden, link, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return link
        }
    }
}

extension UILabel {
    var textLink: Link<String?> {
        if let link = objc_getAssociatedObject(self, &PropertyKey.uiLabel) as? Link<String?> {
            return link
        } else {
            let link = Link<String?>() { [weak self] text in
                DispatchQueue.main.async {
                    self?.text = text
                }
            }
            objc_setAssociatedObject(self, &PropertyKey.uiLabel, link, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return link
        }
    }
}

extension UIImageView {
    var imageLink: Link<UIImage?> {
        if let link = objc_getAssociatedObject(self, &PropertyKey.uiImageView) as? Link<UIImage?> {
            return link
        } else {
            let link = Link<UIImage?>() { [weak self] image in
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
            objc_setAssociatedObject(self, &PropertyKey.uiImageView, link, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return link
        }
    }
}

extension UIBarButtonItem {
    var enabledLink: Link<Bool> {
        if let link = objc_getAssociatedObject(self, &PropertyKey.barButtonItemEnabled) as? Link<Bool> {
            return link
        } else {
            let link = Link<Bool>() { [weak self] enabled in
                DispatchQueue.main.async {
                    self?.isEnabled = enabled
                }
            }
            objc_setAssociatedObject(self, &PropertyKey.barButtonItemEnabled, link, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return link
        }
    }
}

extension CALayer {
    var contentLink: Link<UIImage?> {
        if let link = objc_getAssociatedObject(self, &PropertyKey.caLayerContent) as? Link<UIImage?> {
            return link
        } else {
            let link = Link<UIImage?>() { [weak self] image in
                DispatchQueue.main.async {
                    self?.contents = image?.cgImage
                }
            }
            objc_setAssociatedObject(self, &PropertyKey.caLayerContent, link, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return link
        }
    }
}
