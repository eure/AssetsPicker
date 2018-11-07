//
//  CustomAssetCollectionNib.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/11/07.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import UIKit
import AssetsPicker

class Demo3AssetCollectionNib: UICollectionViewCell, AssetPickAssetCollectionCellCustomization, AssetsCollectionCellViewModelDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    public var cellViewModel: PhotosPicker.AssetsCollectionViewController.CellViewModel?
    
    // MARK: Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        titleLabel.text = " "
    }
    
    // MARK: AssetCollectionCellProtocol
    
    public func bind(cellViewModel: PhotosPicker.AssetsCollectionViewController.CellViewModel) {
        self.cellViewModel = cellViewModel
        self.cellViewModel?.delegate = self
        titleLabel.text = cellViewModel.assetCollection.localizedTitle ?? ""
        
        cellViewModel.fetchLatestImage()
    }
    
    // MARK: AssetsCollectionCellViewModelDelegate
    
    public func cellViewModel(_ cellViewModel: PhotosPicker.AssetsCollectionViewController.CellViewModel, didFetchImage image: UIImage) {
        imageView.image = image
    }
    
    public func cellViewModel(_ cellViewModel: PhotosPicker.AssetsCollectionViewController.CellViewModel, didFetchNumberOfAssets numberOfAssets: String) {
    }
    
}
