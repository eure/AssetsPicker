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

public class Demo2AssetCell: UICollectionViewCell, AssetDetailCellBindable, AssetDetailCellViewModelDelegate {

    // MARK: AssetCellProtocol
    
    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // MARK: Lifecycle
    
    public override var isSelected: Bool {
        didSet {
            updateSelection(isItemSelected: isSelected)
        }
    }
    
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
    
    public var cellViewModel: AssetDetailCellViewModel?
    
    public func bind(cellViewModel: AssetDetailCellViewModel) {
        self.cellViewModel = cellViewModel
        
        self.cellViewModel?.delegate = self
        
        cellViewModel.fetchPreviewImage()
    }
    
    public func updateSelection(isItemSelected: Bool) {
        if isItemSelected {
            imageView.layer.borderColor = UIColor.green.cgColor
            imageView.layer.borderWidth = 2
        } else {
            imageView.layer.borderColor = nil
            imageView.layer.borderWidth = 0

        }
    }
    
    // MARK: AssetDetailCellViewModelDelegate
    
    public func cellViewModel(_ cellViewModel: AssetDetailCellViewModel, didFetchImage image: UIImage) {
        imageView.image = image
    }
}
