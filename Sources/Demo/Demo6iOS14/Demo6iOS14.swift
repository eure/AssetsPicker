//
//  Demo5ViewController.swift
//  AssetsPicker
//
//  Created by Antoine Marandon on 29/07/2019.
//  Copyright © 2019 eureka, Inc. All rights reserved.
//

import MosaiqueAssetsPicker
import UIKit

class Demo6iOS14: UIViewController {
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: User Interaction

    @IBAction func didTapPresentButton(_: Any) {
        present(MosaiqueAssetPickerPresenter.controller(delegate: self), animated: true, completion: nil)
    }

    @IBOutlet var imageView: UIImageView!
}

extension Demo6iOS14: MosaiqueAssetPickerDelegate {
    func photoPicker(_: UIViewController, didPickImages _: [UIImage]) { }

    func photoPicker(_ controller: UIViewController, didPickAssets assets: [AssetFuture]) {
        assets.first?.onComplete = { [weak self] in
            _ = assets // capture
            switch $0 {
            case let .success(image):
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            case let .failure(error):
                print("Failed with \(error)")
            }
        }
        controller.dismiss(animated: true, completion: {})
    }

    func photoPickerDidCancel(_: UIViewController) {
        print("photoPickerDidCancel")
        dismiss(animated: true, completion: nil)
    }
}
