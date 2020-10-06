//
//  Demo4ViewController.swift
//  Demo
//
//  Created by Aymen Rebouh on 2018/11/07.
//  Copyright © 2018 eureka, Inc. All rights reserved.
//

import MosaiqueAssetsPicker
import UIKit

class Demo4ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func didTapPresentButton(_: Any) {
        let headerView = UIView()
        headerView.backgroundColor = .orange
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: 120).isActive = true

        let photoPicker = MosaiqueAssetPickerViewController()
            .setHeaderView(headerView, isHeaderFloating: true)
            .setNumberOfItemsPerRow(5)

        photoPicker.pickerDelegate = self

        present(photoPicker, animated: true, completion: nil)
    }
}

extension Demo4ViewController: MosaiqueAssetPickerDelegate {
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
