//
//  rAssetsCollectionDelegate.Cell.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/18.
//  Copyright © 2018 eureka, Inc. All rights reserved.
//

import Foundation
import UIKit

final class AssetCollectionCell: UICollectionViewCell, AssetCollectionCellBindable {
    // MARK: Properties

    public let assetImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let assetTitleLabel = UILabel()
    private let assetNumberOfItemsLabel = UILabel()
    var cellViewModel: AssetCollectionCellViewModel?

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        appareance: do {
            assetImageView.contentMode = .scaleAspectFill
            assetImageView.layer.cornerRadius = 2
            assetImageView.layer.masksToBounds = true

            if #available(iOS 13.0, *) {
                assetImageView.backgroundColor = UIColor.tertiarySystemFill
                assetTitleLabel.textColor = UIColor.label
                assetNumberOfItemsLabel.textColor = UIColor.secondaryLabel
            } else {
                assetImageView.backgroundColor = UIColor(white: 0, alpha: 0.05)
                assetTitleLabel.textColor = .black
                assetNumberOfItemsLabel.textColor = .lightGray
            }

            assetTitleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
            assetNumberOfItemsLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        }

        layout: do {
            contentView.addSubview(assetImageView)
            contentView.addSubview(assetTitleLabel)
            contentView.addSubview(assetNumberOfItemsLabel)

            assetImageView.translatesAutoresizingMaskIntoConstraints = false
            assetTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            assetNumberOfItemsLabel.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                assetImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
                assetImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
                assetImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),
                assetImageView.widthAnchor.constraint(equalTo: assetImageView.heightAnchor, multiplier: 1.0),

                assetTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                assetTitleLabel.leftAnchor.constraint(equalTo: assetImageView.rightAnchor, constant: 16),
                assetTitleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 16),

                assetNumberOfItemsLabel.topAnchor.constraint(equalTo: assetTitleLabel.bottomAnchor, constant: 4),
                assetNumberOfItemsLabel.leftAnchor.constraint(equalTo: assetTitleLabel.leftAnchor, constant: 0),
                assetNumberOfItemsLabel.rightAnchor.constraint(equalTo: assetTitleLabel.rightAnchor, constant: 0),
            ]
            )
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func prepareForReuse() {
        super.prepareForReuse()

        assetImageView.image = nil
        assetTitleLabel.text = " "
        assetNumberOfItemsLabel.text = " "
    }

    func bind(cellViewModel: AssetCollectionCellViewModel) {
        self.cellViewModel = cellViewModel
        self.cellViewModel?.delegate = self

        assetTitleLabel.text = cellViewModel.assetCollection.localizedTitle ?? ""

        cellViewModel.fetchLatestImage()
    }
}

// MARK: AssetsCollectionCellViewModelDelegate

extension AssetCollectionCell: AssetsCollectionCellViewModelDelegate {
    public func cellViewModel(_: AssetCollectionCellViewModel, didFetchImage image: UIImage) {
        assetImageView.image = image
    }

    public func cellViewModel(_: AssetCollectionCellViewModel, didFetchNumberOfAssets numberOfAssets: String) {
        assetNumberOfItemsLabel.text = numberOfAssets
    }
}
