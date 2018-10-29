//
//  PhotoPicker.PhotosPickerAssetDetailViewController.HeaderContainerView.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/29.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import UIKit

extension PhotosPicker.AssetDetailViewController {

    final class HeaderContainerView : UICollectionReusableView {
        
        func set(view: UIView) {
            
            subviews.forEach { $0.removeFromSuperview() }
            
            addSubview(view)

            view.topAnchor.constraint(equalTo: topAnchor).isActive = true
            view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }
}
