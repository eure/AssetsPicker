//
//  Demo3AssetNib.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/11/07.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import UIKit
import AssetsPicker

class Demo3AssetNib: UICollectionViewCell, AssetPickAssetCellCustomization {
    
    // MARK: Properties
    
    @IBOutlet weak var imageView: UIImageView!
    var cellViewModel: AssetDetailCellViewModel?
    
    // MARK: Lifecycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Core
    
    func bind(cellViewModel: AssetDetailCellViewModel) {
        self.cellViewModel = cellViewModel
        
        self.cellViewModel?.delegate = self
        cellViewModel.fetchPreviewImage()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
}

extension Demo3AssetNib: AssetDetailCellViewModelDelegate {
    func cellViewModel(_ cellViewModel: AssetDetailCellViewModel, didFetchImage image: UIImage) {
        imageView.image = image
    }
}
