//
//  CustomCellDemoViewController.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/11/01.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import UIKit
import AssetsPicker

class Demo2ViewController: UIViewController {
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: User Interaction
    
    @IBAction func didTapPresentButton(_ sender: Any) {
        let configuration = PhotosPicker.Configuration()
        
        configuration.cellRegistrator.register(cellClass: Demo2AssetCell.self, forCellType: .asset)
        configuration.cellRegistrator.register(cellClass: Demo2AssetCollectionCell.self, forCellType: .assetCollection)
        
        let photoPicker = PhotosPicker.ViewController(withConfiguration: configuration)
        photoPicker.pickerDelegate = self
        
        present(photoPicker, animated: true, completion: nil)
    }
}

extension Demo2ViewController: PhotosPickerDelegate {
    func photoPicker(_ pickerController: PhotosPicker.ViewController, didPickImages images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
        print("main didPickImages = \(images)")
    }
}
