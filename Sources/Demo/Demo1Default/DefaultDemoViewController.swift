//
//  DefaultDemoViewController.swift
//  Demo
//
//  Created by muukii on 10/13/18.
//  Copyright © 2018 eureka, Inc. All rights reserved.
//

import UIKit
import MosaiqueAssetsPicker

class DemoDefaultViewController: UIViewController {
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: User Interaction

    @IBAction func didTapPresentButton(_ sender: Any) {
        let photoPicker = MosaiqueAssetPickerViewController()
        photoPicker.pickerDelegate = self
        photoPicker.setMediaTypes([.image, .video])
        photoPicker.setCellSpacing(2.0)
        present(photoPicker, animated: true, completion: nil)
    }
}

extension DemoDefaultViewController: MosaiqueAssetPickerDelegate {
    func photoPicker(_ controller: UIViewController, didPickAssets assets: [AssetFuture]) {
    }

    func photoPicker(_ controller: UIViewController, didPickImages images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
        print("main didPickImages = \(images)")
    }
    
    func photoPickerDidCancel(_ controller: UIViewController) {
        print("photoPickerDidCancel")
        self.dismiss(animated: true, completion: nil)
    }
}
