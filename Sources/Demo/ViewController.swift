//
//  ViewController.swift
//  Demo
//
//  Created by muukii on 10/13/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit
import AssetsPicker

class ViewController: UIViewController {
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: User Interaction

    @IBAction func didTapPresentButton(_ sender: Any) {
        let headerView = UIView()
        headerView.backgroundColor = .lightGray
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: 120).isActive = true


        let configuration = PhotosPicker.Configuration(
            selectionMode: .single,
            selectionColor: #colorLiteral(red: 0.4156862745, green: 0.768627451, blue: 0.8117647059, alpha: 1),
            tintColor: #colorLiteral(red: 0.4156862745, green: 0.768627451, blue: 0.8117647059, alpha: 1),
            numberOfItemsInRow: 4,
            headerView: headerView,
            isHeaderFloating: true
        )

        let photoPicker = PhotosPicker.ViewController(withConfiguration: configuration)
        photoPicker.pickerDelegate = self
        present(photoPicker, animated: true, completion: nil)
    }
}

extension ViewController: PhotosPickerDelegate {
    func photoPicker(_ pickerController: PhotosPicker.ViewController, didPickImages images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
        print("main didPickImages = \(images)")
    }
}
