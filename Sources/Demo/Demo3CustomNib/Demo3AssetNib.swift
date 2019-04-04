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
    
    public override var isSelected: Bool {
        didSet {
            updateSelection(isItemSelected: isSelected)
        }
    }
    
    // MARK: Lifecycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func updateSelection(isItemSelected: Bool) {
        if isItemSelected {
            imageView.layer.borderColor = UIColor.purple.cgColor
            imageView.layer.borderWidth = 4
        } else {
            imageView.layer.borderColor = nil
            imageView.layer.borderWidth = 0
        }
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
