//
//  Demo5ViewController.swift
//  AssetsPicker
//
//  Created by Antoine Marandon on 29/07/2019.
//  Copyright © 2019 eureka, Inc. All rights reserved.
//

import MosaiqueAssetsPicker
import UIKit

class Demo5MultipleAssetSelection: UIViewController {
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: User Interaction

    @IBAction func didTapPresentButton(_: Any) {
        let photoPicker = MosaiqueAssetPickerViewController()
        photoPicker.setSelectionMode(.multiple(limit: 3))
        photoPicker.pickerDelegate = self

        present(photoPicker, animated: true, completion: nil)
    }
}

extension Demo5MultipleAssetSelection: MosaiqueAssetPickerDelegate {
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
