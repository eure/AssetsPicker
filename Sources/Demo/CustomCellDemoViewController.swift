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

class CustomCellDemoViewController: UIViewController {
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: User Interaction
    
    @IBAction func didTapPresentButton(_ sender: Any) {
        let headerView = UIView()
        headerView.backgroundColor = .lightGray
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        var configuration = PhotosPicker.Configuration()
        configuration.selectionMode = .multiple(limit: 4)
        configuration.selectionColor =  #colorLiteral(red: 0.4156862745, green: 0.768627451, blue: 0.8117647059, alpha: 1)
        configuration.tintColor = #colorLiteral(red: 0.4156862745, green: 0.768627451, blue: 0.8117647059, alpha: 1)
        configuration.numberOfItemsInRow = 3
        configuration.headerView = headerView
        configuration.isHeaderFloating = true
        configuration.disableOnLibraryScrollAnimation = true
        
        configuration.cellRegistrator.register(cellClass: CustomAssetCell.self, forCellType: .asset)
        configuration.cellRegistrator.register(cellClass: CustomAssetCollectionCell.self, forCellType: .assetCollection)
        
        let photoPicker = PhotosPicker.ViewController(withConfiguration: configuration)
        photoPicker.pickerDelegate = self
        present(photoPicker, animated: true, completion: nil)
    }
}

extension CustomCellDemoViewController: PhotosPickerDelegate {
    func photoPicker(_ pickerController: PhotosPicker.ViewController, didPickImages images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
        print("main didPickImages = \(images)")
    }
}
