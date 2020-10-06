//
//  DefaultDemoViewController.swift
//  Demo
//
//  Created by muukii on 10/13/18.
//  Copyright © 2018 eureka, Inc. All rights reserved.
//

import MosaiqueAssetsPicker
import UIKit

class DemoDefaultViewController: UIViewController {
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: User Interaction

    @IBAction func didTapPresentButton(_: Any) {
        let photoPicker = MosaiqueAssetPickerViewController()
        photoPicker.pickerDelegate = self
        photoPicker.setMediaTypes([.image, .video])
        photoPicker.setCellSpacing(2.0)
        present(photoPicker, animated: true, completion: nil)
    }
}

extension DemoDefaultViewController: MosaiqueAssetPickerDelegate {
    func photoPicker(_: UIViewController, didPickAssets _: [AssetFuture]) {}

    func photoPicker(_: UIViewController, didPickImages images: [UIImage]) {
        dismiss(animated: true, completion: nil)
        print("main didPickImages = \(images)")
    }

    func photoPickerDidCancel(_: UIViewController) {
        print("photoPickerDidCancel")
        dismiss(animated: true, completion: nil)
    }
}
