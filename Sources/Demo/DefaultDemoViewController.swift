//
//  DefaultDemoViewController.swift
//  Demo
//
//  Created by muukii on 10/13/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit
import AssetsPicker

class DefaultDemoViewController: UIViewController {
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: User Interaction

    @IBAction func didTapPresentButton(_ sender: Any) {
        let configuration = PhotosPicker.Configuration()
        let photoPicker = PhotosPicker.ViewController(withConfiguration: configuration)
        photoPicker.pickerDelegate = self
        present(photoPicker, animated: true, completion: nil)
    }
}

extension DefaultDemoViewController: PhotosPickerDelegate {
    func photoPicker(_ pickerController: PhotosPicker.ViewController, didPickImages images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
        print("main didPickImages = \(images)")
    }
}
