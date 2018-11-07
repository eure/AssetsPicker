//
//  PhotosPickerController.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/16.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import UIKit

public enum PhotosPicker {}

public protocol PhotosPickerDelegate: class {
    func photoPicker(_ pickerController: PhotosPicker.ViewController, didPickImages images: [UIImage])
}

let PhotoPickerPickImageNotification = "PhotoPickerPickImageNotification"

extension PhotosPicker {
    
    public final class ViewController : UINavigationController {
        
        // MARK: - Properties
        
        public weak var pickerDelegate: PhotosPickerDelegate?
        
        // MARK: - Lifecycle

        public init(withConfiguration configuration: PhotosPicker.Configuration) {
            super.init(nibName: nil, bundle: nil)
            
            PhotosPicker.Configuration.shared = configuration
            
            setupRootController: do  {
                let controller = PhotosPicker.SelectAssetCollectionContainerViewController()
                pushViewController(controller, animated: false)
            }
            setupPickImagesNotification: do {
                NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: PhotoPickerPickImageNotification), object: nil, queue: nil) { [weak self] notification in
                    guard let `self` = self else { return }
                    if let images = notification.object as? [UIImage] {
                        self.pickerDelegate?.photoPicker(self, didPickImages: images)
                    }
                }
            }
        }
        
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }
    }
}
