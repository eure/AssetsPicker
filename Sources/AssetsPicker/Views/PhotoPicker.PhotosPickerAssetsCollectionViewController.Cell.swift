//
//  PhotoPicker.PhotosPickerAssetsCollectionDelegate.Cell.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/18.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import UIKit

extension PhotosPicker.AssetsCollectionViewController {
    
    final class Cell: UICollectionViewCell, AssetPickAssetCollectionCellCustomization {
        
        // MARK: Properties
        
        public let assetImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
        
        private let assetTitleLabel = UILabel()
        private let assetNumberOfItemsLabel = UILabel()
        var cellViewModel: CellViewModel?

        // MARK: Lifecycle
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            appareance: do {
                assetImageView.backgroundColor = UIColor(white: 0, alpha: 0.05)
                assetImageView.contentMode = .scaleAspectFill
                assetImageView.layer.cornerRadius = 2
                assetImageView.layer.masksToBounds = true

                assetTitleLabel.textColor = .black // To be replaced by appareance theme
                assetNumberOfItemsLabel.textColor = .lightGray // To be replaced by appareance theme
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
                        assetImageView.widthAnchor.constraint(equalToConstant: 64),
                        assetImageView.heightAnchor.constraint(equalToConstant: 64),
                        
                        assetTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                        assetTitleLabel.leftAnchor.constraint(equalTo: assetImageView.rightAnchor, constant: 16),
                        assetTitleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 16),
                        
                        assetNumberOfItemsLabel.topAnchor.constraint(equalTo: assetTitleLabel.bottomAnchor, constant: 4),
                        assetNumberOfItemsLabel.leftAnchor.constraint(equalTo: assetTitleLabel.leftAnchor, constant: 0),
                        assetNumberOfItemsLabel.rightAnchor.constraint(equalTo: assetTitleLabel.rightAnchor, constant: 0)
                    ]
                )
            }
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func prepareForReuse() {
            super.prepareForReuse()
            
            assetImageView.image = nil
            assetTitleLabel.text = " "
            assetNumberOfItemsLabel.text = " "
        }
        
        func bind(cellViewModel: CellViewModel) {
            self.cellViewModel = cellViewModel
            self.cellViewModel?.delegate = self
            assetTitleLabel.text = cellViewModel.assetCollection.localizedTitle ?? ""
            
            cellViewModel.fetchLatestImage()
        }
    }
}

extension PhotosPicker.AssetsCollectionViewController.Cell: AssetsCollectionCellViewModelDelegate {
    public func cellViewModel(_ cellViewModel: PhotosPicker.AssetsCollectionViewController.CellViewModel, didFetchImage image: UIImage) {
        assetImageView.image = image
    }
    
    public func cellViewModel(_ cellViewModel: PhotosPicker.AssetsCollectionViewController.CellViewModel, didFetchNumberOfAssets numberOfAssets: String) {
        assetNumberOfItemsLabel.text = numberOfAssets
    }
}
