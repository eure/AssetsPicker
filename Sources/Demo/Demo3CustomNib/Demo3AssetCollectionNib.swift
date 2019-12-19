//
//  CustomAssetCollectionNib.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/11/07.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import UIKit
import MosaiqueAssetsPicker

class Demo3AssetCollectionNib: UICollectionViewCell, AssetCollectionCellBindable, AssetsCollectionCellViewModelDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    public var cellViewModel: AssetCollectionCellViewModel?
    
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
    
    public func bind(cellViewModel: AssetCollectionCellViewModel) {
        self.cellViewModel = cellViewModel
        self.cellViewModel?.delegate = self
        titleLabel.text = cellViewModel.assetCollection.localizedTitle ?? ""
        
        cellViewModel.fetchLatestImage()
    }
    
    // MARK: AssetsCollectionCellViewModelDelegate
    
    public func cellViewModel(_ cellViewModel: AssetCollectionCellViewModel, didFetchImage image: UIImage) {
        imageView.image = image
    }
    
    public func cellViewModel(_ cellViewModel: AssetCollectionCellViewModel, didFetchNumberOfAssets numberOfAssets: String) {
    }
    
}
