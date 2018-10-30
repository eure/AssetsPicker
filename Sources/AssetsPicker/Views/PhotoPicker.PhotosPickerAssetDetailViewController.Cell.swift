//
//  PhotoPicker.PhotosPickerAssetDetailViewController.Cell.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/19.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import UIKit

extension PhotosPicker.AssetDetailViewController {
    
    // MARK: Inner
    
    private final class SelectedView: UIView {
        
        // MARK: Properties
        
        private let borderLayer: CAShapeLayer = {
           let layer = CAShapeLayer()
            layer.borderColor = PhotosPicker.Configuration.shared.selectionColor.cgColor
            layer.borderWidth = 4
            
            return layer
        }()

        // MARK: Lifecycle
        
        init() {
            super.init(frame: .zero)
            
            layer.addSublayer(borderLayer)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSublayers(of layer: CALayer) {
            super.layoutSublayers(of: layer)
            
            borderLayer.frame = self.layer.bounds
        }
    }
    
    final class Cell: UICollectionViewCell, AssetPickAssetCellCustomization {
        
        // MARK: Properties
        
        private let selectedView = SelectedView()
        public let assetImageLayer: CALayer = {
            let layer = CALayer()
            layer.masksToBounds = true
            layer.contentsGravity = .resizeAspectFill
            
            return layer
        }()

        private(set) var cellViewModel: CellViewModel?
        
        // MARK: Lifecycle
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            layout: do {
                contentView.layer.addSublayer(assetImageLayer)
                contentView.addSubview(selectedView)
                
                selectedView.isHidden = true
                selectedView.translatesAutoresizingMaskIntoConstraints = false
                selectedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
                selectedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
                selectedView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0).isActive = true
                selectedView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0).isActive = true
            }
        }
        
        public override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
            return layoutAttributes
        }
        
        public override func layoutSublayers(of layer: CALayer) {
            super.layoutSublayers(of: layer)
            
            assetImageLayer.frame = self.bounds
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: Core

        func bind(cellViewModel: CellViewModel) {
            self.cellViewModel = cellViewModel
            
            //updateSelectionView()
            
            self.cellViewModel?.delegate = self
            cellViewModel.fetchPreviewImage()
        }
        
        
        func updateSelection(isItemSelected: Bool) {
            self.selectedView.isHidden = !isItemSelected
        }
        
        public override func prepareForReuse() {
            super.prepareForReuse()
            
            assetImageLayer.contents = nil
            selectedView.isHidden = true
            cellViewModel?.cancelImageIfNeeded()
            cellViewModel?.delegate = nil
            cellViewModel = nil
        }
    }
}

extension PhotosPicker.AssetDetailViewController.Cell: AssetDetailCellViewModelDelegate {
    func cellViewModel(_ cellViewModel: PhotosPicker.AssetDetailViewController.CellViewModel, didFetchImage image: UIImage) {
        assetImageLayer.contents = image.cgImage
    }
}
