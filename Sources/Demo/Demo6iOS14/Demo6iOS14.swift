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
    func photoPicker(_ controller: UIViewController, didPickImages images: [UIImage]) {

    }

    func photoPicker(_: UIViewController, didPickAssets  assets: [AssetFuture]) {
        assets.first?.onComplete = {
            switch $0 {
            case .success(let image):
                print("Success!")
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
                    //WEAK
            case .failure(let error):
                print("Failed with \(error)")
            }
        }
    }

    func photoPickerDidCancel(_: UIViewController) {
        print("photoPickerDidCancel")
        dismiss(animated: true, completion: nil)
    }
}
