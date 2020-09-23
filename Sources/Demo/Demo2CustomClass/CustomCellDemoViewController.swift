//
//  CustomCellDemoViewController.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/11/01.
//  Copyright © 2018 eureka, Inc. All rights reserved.
//

import Foundation
import UIKit
import MosaiqueAssetsPicker

class Demo2ViewController: UIViewController {
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: User Interaction
    
    @IBAction func didTapPresentButton(_ sender: Any) {

        let cellRegistrator = AssetPickerCellRegistrator()
        cellRegistrator.register(cellClass: Demo2AssetCell.self, forCellType: .asset)
        cellRegistrator.register(cellClass: Demo2AssetCollectionCell.self, forCellType: .assetCollection)
        
        let photoPicker = MosaiqueAssetPickerViewController()
                            .setCellRegistrator(cellRegistrator)
                            .setSelectionMode(.multiple(limit: 5))
        
        photoPicker.pickerDelegate = self
        
        present(photoPicker, animated: true, completion: nil)
    }
}

extension Demo2ViewController: MosaiqueAssetPickerDelegate {
    func photoPicker(_ controller: UIViewController, didPickAssets assets: [AssetFuture]) { }


    func photoPicker(_ controller: UIViewController, didPickImages images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
        print("main didPickImages = \(images)")
    }
    
    func photoPickerDidCancel(_ pickerController: MosaiqueAssetPickerViewController) {
        print("photoPickerDidCancel")
        self.dismiss(animated: true, completion: nil)
    }
}
