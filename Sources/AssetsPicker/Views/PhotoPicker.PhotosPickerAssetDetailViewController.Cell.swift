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
        
        override var isSelected: Bool {
            didSet {
                selectedView.isHidden = !isSelected
            }
        }        
        
        private let selectedView = SelectedView()
        
        public let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()

        var cellViewModel: CellViewModel?
        
        // MARK: Lifecycle
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            layout: do {
                contentView.addSubview(imageView)
                contentView.addSubview(selectedView)

                imageView.translatesAutoresizingMaskIntoConstraints = false
                selectedView.translatesAutoresizingMaskIntoConstraints = false

                NSLayoutConstraint.activate([
                    imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                    imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                    imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                    imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                    
                    selectedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
                    selectedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
                    selectedView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
                    selectedView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0)
                    ]
                )

                selectedView.isHidden = true

            }
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: Core

        func bind(cellViewModel: CellViewModel) {
            self.cellViewModel = cellViewModel
                        
            self.cellViewModel?.delegate = self
            cellViewModel.fetchPreviewImage()
        }

        public override func prepareForReuse() {
            super.prepareForReuse()
            
            imageView.image = nil
            selectedView.isHidden = true
        }
    }
}

extension PhotosPicker.AssetDetailViewController.Cell: AssetDetailCellViewModelDelegate {
    func cellViewModel(_ cellViewModel: PhotosPicker.AssetDetailViewController.CellViewModel, didFetchImage image: UIImage) {
        imageView.image = image
    }
}
