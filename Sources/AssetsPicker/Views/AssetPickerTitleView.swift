//
//  PhotoPicker.TitleView.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/23.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import UIKit

final class AssetPickerTitleView : UIButton {
    
    // MARK: Lifecycle
    
    convenience init() {
        self.init(frame: .zero)
        
        setup()
    }
    
    // MARK: Setup
    
    func setup() {
        
        // Flip button title and button image
        let flippedTransform = CGAffineTransform(scaleX: -1, y: 1)
        transform = flippedTransform
        titleLabel?.transform = flippedTransform
        imageView?.transform = flippedTransform
        
        // Space between image and title
        let arrowDownImage = UIImage(named: "icon_arrow_down", in: Bundle.main, compatibleWith: nil)
        setImage(arrowDownImage, for: .normal)
        imageEdgeInsets.left = -10
        
        setTitleColor(.black, for: .normal)
        setTitle(AssetPickerConfiguration.shared.localize.collections, for: .normal)
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
    }
    
    func setOpened() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                self.imageView?.transform = CGAffineTransform(rotationAngle: -.pi)
        })
    }
    
    func setClosed() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                self.imageView?.transform = .identity
        })
    }
}
