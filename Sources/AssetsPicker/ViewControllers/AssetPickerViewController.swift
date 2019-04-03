//
//  PhotosPickerController.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/16.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import UIKit

public protocol AssetPickerDelegate: class {
    func photoPicker(_ pickerController: AssetPickerViewController, didPickImages images: [UIImage])
}

let PhotoPickerPickImageNotification = "PhotoPickerPickImageNotification"


public final class AssetPickerViewController : UINavigationController {
    
    // MARK: - Properties
    
    public weak var pickerDelegate: AssetPickerDelegate?
    
    // MARK: - Lifecycle
    
    public init(withConfiguration configuration: AssetPickerConfiguration) {
        super.init(nibName: nil, bundle: nil)
        
        AssetPickerConfiguration.shared = configuration
        
        setupRootController: do  {
            let controller = SelectAssetCollectionContainerViewController()
            pushViewController(controller, animated: false)
        }
        
        setupPickImagesNotification: do {
            NotificationCenter.default.addObserver(self, selector: #selector(didPickImages(notification:)), name: NSNotification.Name(rawValue: PhotoPickerPickImageNotification), object: nil)
        }
    }
    
    @objc func didPickImages(notification: Notification) {
        if let images = notification.object as? [UIImage] {
            self.pickerDelegate?.photoPicker(self, didPickImages: images)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
}
