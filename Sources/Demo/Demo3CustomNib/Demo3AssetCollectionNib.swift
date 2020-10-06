//
//  CustomAssetCollectionNib.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/11/07.
//  Copyright © 2018 eureka, Inc. All rights reserved.
//

import Foundation
import MosaiqueAssetsPicker
import UIKit

class Demo3AssetCollectionNib: UICollectionViewCell, AssetCollectionCellBindable, AssetsCollectionCellViewModelDelegate {
    // MARK: Properties

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    public var cellViewModel: AssetCollectionCellViewModel?

    // MARK: Lifecycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
        titleLabel.text = " "
    }

    // MARK: AssetCollectionCellProtocol

    public func bind(cellViewModel: AssetCollectionCellViewModel) {
        self.cellViewModel = cellViewModel
        self.cellViewModel?.delegate = self
        titleLabel.text = cellViewModel.assetCollection.localizedTitle ?? ""

        cellViewModel.fetchLatestImage()
    }

    // MARK: AssetsCollectionCellViewModelDelegate

    public func cellViewModel(_: AssetCollectionCellViewModel, didFetchImage image: UIImage) {
        imageView.image = image
    }

    public func cellViewModel(_: AssetCollectionCellViewModel, didFetchNumberOfAssets _: String) {}
}
