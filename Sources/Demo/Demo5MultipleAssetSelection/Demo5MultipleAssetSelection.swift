//
//  Demo5ViewController.swift
//  AssetsPicker
//
//  Created by Antoine Marandon on 29/07/2019.
//  Copyright © 2019 eure. All rights reserved.
//

import UIKit
import MosaiqueAssetsPicker

class Demo5MultipleAssetSelection: UIViewController {
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: User Interaction
    
    @IBAction func didTapPresentButton(_ sender: Any) {
        let photoPicker = MosaiqueAssetPickerViewController()
        photoPicker.setSelectionMode(.multiple(limit: 3))
        photoPicker.pickerDelegate = self
        
        present(photoPicker, animated: true, completion: nil)
    }
}

extension Demo5MultipleAssetSelection: MosaiqueAssetPickerDelegate {
    func photoPicker(_ pickerController: MosaiqueAssetPickerViewController, didPickImages images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
        print("main didPickImages = \(images)")
    }
    
    func photoPickerDidCancel(_ pickerController: MosaiqueAssetPickerViewController) {
        print("photoPickerDidCancel")
        self.dismiss(animated: true, completion: nil)
    }
}
