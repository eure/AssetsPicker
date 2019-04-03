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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    func setup() {
        let flippedTransform = CGAffineTransform(scaleX: -1, y: 1)
        transform = flippedTransform
        titleLabel?.transform = flippedTransform
        imageView?.transform = flippedTransform
        
        let arrowDownImage = UIImage(named: "icon_arrow_down", in: Bundle.main, compatibleWith: nil)
        setImage(arrowDownImage, for: .normal)
        imageEdgeInsets.left = -10
        
        setTitleColor(.black, for: .normal)
        setTitle(AssetPickerConfiguration.shared.localize.collections, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    }
    
    func setOpened() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [
                .beginFromCurrentState,
                .allowUserInteraction
            ],
            animations: {
                self.imageView?.transform = CGAffineTransform(rotationAngle: -.pi)
        }) { (finish) in
            
        }
    }
    
    func setClosed() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [
                .beginFromCurrentState,
                .allowUserInteraction
            ],
            animations: {
                self.imageView?.transform = .identity
        }) { (finish) in
            
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

