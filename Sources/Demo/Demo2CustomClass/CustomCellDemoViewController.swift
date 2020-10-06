//
//  CustomCellDemoViewController.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/11/01.
//  Copyright © 2018 eureka, Inc. All rights reserved.
//

import Foundation
import MosaiqueAssetsPicker
import UIKit

class Demo2ViewController: UIViewController {
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: User Interaction

    @IBAction func didTapPresentButton(_: Any) {
        let cellRegistrator = AssetPickerCellRegistrator()
        cellRegistrator.register(cellClass: Demo2AssetCell.self, forCellType: .asset)
        cellRegistrator.register(cellClass: Demo2AssetCollectionCell.self, forCellType: .assetCollection)

        let photoPicker = MosaiqueAssetPickerViewController()
            .setCellRegistrator(cellRegistrator)
            .setSelectionMode(.multiple(limit: 5))

        photoPicker.pickerDelegate = self

        present(photoPicker, animated: true, completion: nil)
    }
}

extension Demo2ViewController: MosaiqueAssetPickerDelegate {
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
