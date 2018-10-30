//
//  CustomAssetCollectionCell.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/31.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary

public class CustomAssetCollectionCell: UICollectionViewCell, AssetPickAssetCollectionCellCustomization, AssetsCollectionCellViewModelDelegate {
    
    // MARK: Properties
    
    public let assetImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let assetTitleLabel = UILabel()
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        appareance: do {
            assetImageView.backgroundColor = UIColor(white: 0, alpha: 0.05)
            assetImageView.contentMode = .scaleAspectFill
            assetImageView.layer.cornerRadius = 2
            assetImageView.layer.masksToBounds = true
            
            assetTitleLabel.font = UIFont.boldSystemFont(ofSize: 22)
            assetTitleLabel.textColor = .black // To be replaced by appareance theme
        }
        layout: do {
            contentView.addSubview(assetImageView)
            contentView.addSubview(assetTitleLabel)
            
            assetImageView.translatesAutoresizingMaskIntoConstraints = false
            assetImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
            assetImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
            assetImageView.widthAnchor.constraint(equalToConstant: 64).isActive = true
            assetImageView.heightAnchor.constraint(equalToConstant: 64).isActive = true
            
            assetTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            assetTitleLabel.centerYAnchor.constraint(equalTo: assetImageView.centerYAnchor, constant: 0).isActive = true
            assetTitleLabel.leftAnchor.constraint(equalTo: assetImageView.rightAnchor, constant: 16).isActive = true
            assetTitleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 16).isActive = true
        }
        binding: do {
            
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        assetImageView.image = nil
        cellViewModel?.cancelLatestImageIfNeeded()
        cellViewModel?.delegate = nil
        cellViewModel = nil
        assetTitleLabel.text = " "
    }
    
    // MARK: AssetCollectionCellProtocol
    
    public var cellViewModel: PhotosPicker.AssetsCollectionViewController.CellViewModel?
    
    public func bind(cellViewModel: PhotosPicker.AssetsCollectionViewController.CellViewModel) {
        self.cellViewModel = cellViewModel
        self.cellViewModel?.delegate = self
        assetTitleLabel.text = cellViewModel.assetCollection.localizedTitle ?? ""
        
        cellViewModel.fetchLatestImage()
    }
    
    // MARK: AssetsCollectionCellViewModelDelegate
    
    public func cellViewModel(_ cellViewModel: PhotosPicker.AssetsCollectionViewController.CellViewModel, didFetchImage image: UIImage) {
        assetImageView.image = image
    }
    
    public func cellViewModel(_ cellViewModel: PhotosPicker.AssetsCollectionViewController.CellViewModel, didFetchNumberOfAssets numberOfAssets: String) {}
}