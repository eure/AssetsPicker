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
    
    public final class Cell: UICollectionViewCell {
        
        // MARK: Properties
        
        private let assetImageLayer: CALayer = {
            let layer = CALayer()
            layer.masksToBounds = true
            layer.contentsGravity = .resizeAspectFill
            
            return layer
        }()
        
        private let assetImageView = UIView()
        private let assetTitleLabel = UILabel()
        private let assetNumberOfItemsLabel = UILabel()
        private(set) var cellViewModel: CellViewModel?

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
                assetImageView.layer.addSublayer(assetImageLayer)
                contentView.addSubview(assetTitleLabel)
                contentView.addSubview(assetNumberOfItemsLabel)

                assetImageView.translatesAutoresizingMaskIntoConstraints = false
                assetImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
                assetImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
                assetImageView.widthAnchor.constraint(equalToConstant: 64).isActive = true
                assetImageView.heightAnchor.constraint(equalToConstant: 64).isActive = true

                assetTitleLabel.translatesAutoresizingMaskIntoConstraints = false
                assetTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
                assetTitleLabel.leftAnchor.constraint(equalTo: assetImageView.rightAnchor, constant: 16).isActive = true
                assetTitleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 16).isActive = true

                assetNumberOfItemsLabel.translatesAutoresizingMaskIntoConstraints = false
                assetNumberOfItemsLabel.topAnchor.constraint(equalTo: assetTitleLabel.bottomAnchor, constant: 4).isActive = true
                assetNumberOfItemsLabel.leftAnchor.constraint(equalTo: assetTitleLabel.leftAnchor, constant: 0).isActive = true
                assetNumberOfItemsLabel.rightAnchor.constraint(equalTo: assetTitleLabel.rightAnchor, constant: 0).isActive = true
            }
            binding: do {

            }
        }
        
        public override func layoutSublayers(of layer: CALayer) {
            super.layoutSublayers(of: layer)
            
            assetImageLayer.frame = assetImageView.bounds
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func prepareForReuse() {
            super.prepareForReuse()
            
            cellViewModel?.cancelLatestImageIfNeeded()
            cellViewModel?.firstAssetInCollection.purge()
            cellViewModel?.assetCount.purge()
            cellViewModel = nil
            assetTitleLabel.text = " "
            assetNumberOfItemsLabel.text = " "
        }
        
        func bind(cellViewModel: CellViewModel) {
            self.cellViewModel = cellViewModel
            
            assetTitleLabel.text = cellViewModel.assetCollection.localizedTitle ?? ""
            assetImageLayer.contentLink.bind(data: cellViewModel.firstAssetInCollection)
            assetNumberOfItemsLabel.textLink.bind(data: cellViewModel.assetCount)
            
            cellViewModel.fetchLatestImage()
        }
    }
}
