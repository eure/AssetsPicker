//
//  Demo3AssetNib.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/11/07.
//  Copyright © 2018 eureka, Inc. All rights reserved.
//

import Foundation
import MosaiqueAssetsPicker
import UIKit

class Demo3AssetNib: UICollectionViewCell, AssetDetailCellBindable {
    // MARK: Properties

    @IBOutlet var imageView: UIImageView!
    var cellViewModel: AssetDetailCellViewModel?

    override public var isSelected: Bool {
        didSet {
            updateSelection(isItemSelected: isSelected)
        }
    }

    // MARK: Lifecycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func updateSelection(isItemSelected: Bool) {
        if isItemSelected {
            imageView.layer.borderColor = UIColor.purple.cgColor
            imageView.layer.borderWidth = 4
        } else {
            imageView.layer.borderColor = nil
            imageView.layer.borderWidth = 0
        }
    }

    // MARK: Core

    func bind(cellViewModel: AssetDetailCellViewModel) {
        self.cellViewModel = cellViewModel

        self.cellViewModel?.delegate = self
        cellViewModel.fetchPreviewImage()
    }

    override public func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
    }
}

extension Demo3AssetNib: AssetDetailCellViewModelDelegate {
    func cellViewModel(_: AssetDetailCellViewModel, didFetchImage image: UIImage) {
        imageView.image = image
    }
}
