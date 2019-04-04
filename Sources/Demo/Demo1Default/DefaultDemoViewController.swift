//
//  DefaultDemoViewController.swift
//  Demo
//
//  Created by muukii on 10/13/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit
import AssetsPicker

class DemoDefaultViewController: UIViewController {
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: User Interaction

    @IBAction func didTapPresentButton(_ sender: Any) {
        let photoPicker = AssetPickerViewController()
        photoPicker.pickerDelegate = self
        
        present(photoPicker, animated: true, completion: nil)
    }
}

extension DemoDefaultViewController: AssetPickerDelegate {
    func photoPicker(_ pickerController: AssetPickerViewController, didPickImages images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
        print("main didPickImages = \(images)")
    }
    
    func photoPickerDidCancel(_ pickerController: AssetPickerViewController) {
        print("photoPickerDidCancel")
        self.dismiss(animated: true, completion: nil)
    }
}
