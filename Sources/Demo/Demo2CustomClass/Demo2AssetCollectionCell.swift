//
//  CustomAssetCollectionCell.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/31.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import UIKit
import MosaiqueAssetsPicker

public class Demo2AssetCollectionCell: UICollectionViewCell, AssetCollectionCellBindable, AssetsCollectionCellViewModelDelegate {
    
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
            assetTitleLabel.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                assetImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
                assetImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
                assetImageView.widthAnchor.constraint(equalToConstant: 64),
                assetImageView.heightAnchor.constraint(equalToConstant: 64),
                
                assetTitleLabel.centerYAnchor.constraint(equalTo: assetImageView.centerYAnchor, constant: 0),
                assetTitleLabel.leftAnchor.constraint(equalTo: assetImageView.rightAnchor, constant: 16),
                assetTitleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 16)
            ])
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
    
    public var cellViewModel: AssetCollectionCellViewModel?
    
    public func bind(cellViewModel: AssetCollectionCellViewModel) {
        self.cellViewModel = cellViewModel
        self.cellViewModel?.delegate = self
        assetTitleLabel.text = cellViewModel.assetCollection.localizedTitle ?? ""
        
        cellViewModel.fetchLatestImage()
    }
    
    // MARK: AssetsCollectionCellViewModelDelegate
    
    public func cellViewModel(_ cellViewModel: AssetCollectionCellViewModel, didFetchImage image: UIImage) {
        assetImageView.image = image
    }
    
    public func cellViewModel(_ cellViewModel: AssetCollectionCellViewModel, didFetchNumberOfAssets numberOfAssets: String) {}
}
