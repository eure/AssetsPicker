//
//  Demo5ViewController.swift
//  AssetsPicker
//
//  Created by Antoine Marandon on 29/07/2019.
//  Copyright © 2019 eureka, Inc. All rights reserved.
//

import UIKit
import MosaiqueAssetsPicker

class Demo6iOS14: UIViewController {
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: User Interaction

    @IBAction func didTapPresentButton(_ sender: Any) {
        present(MosaiqueAssetPickerPresenter.controller(delegate: self), animated: true, completion: nil)
    }
}

extension Demo6iOS14: MosaiqueAssetPickerDelegate {
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
