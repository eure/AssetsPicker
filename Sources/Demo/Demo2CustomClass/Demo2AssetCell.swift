//
//  CustomAssetCell.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/30.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import UIKit
import AssetsPicker

public class Demo2AssetCell: UICollectionViewCell, AssetPickAssetCellCustomization, AssetDetailCellViewModelDelegate {
    
    // MARK: AssetCellProtocol
    
    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layout: do {
            contentView.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                    imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                    imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                    imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                    imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
                ]
            )

        }
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: AssetCellProtocol
    
    public var cellViewModel: PhotosPicker.AssetDetailViewController.CellViewModel?
    
    public func bind(cellViewModel: PhotosPicker.AssetDetailViewController.CellViewModel) {
        self.cellViewModel = cellViewModel
        
        self.cellViewModel?.delegate = self
        
        cellViewModel.fetchPreviewImage()
    }
    
    public func updateSelection(isItemSelected: Bool) {
        print("custom cell updateSelectionView = \(isItemSelected)")
    }
    
    // MARK: AssetDetailCellViewModelDelegate
    
    public func cellViewModel(_ cellViewModel: PhotosPicker.AssetDetailViewController.CellViewModel, didFetchImage image: UIImage) {
        imageView.image = image
    }
}
