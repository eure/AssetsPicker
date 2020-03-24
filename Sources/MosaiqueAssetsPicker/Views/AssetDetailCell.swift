//
//  AssetDetailViewController.Cell.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/19.
//  Copyright © 2018 eureka, Inc. All rights reserved.
//

import Foundation
import UIKit

final class AssetDetailCell: UICollectionViewCell, AssetDetailCellBindable {
    var configuration: MosaiqueAssetPickerConfiguration!
    // MARK: Properties
    private var spinner: UIActivityIndicatorView?
    
    override var isSelected: Bool {
        didSet {
            updateSelection(isItemSelected: isSelected)
        }
    }        
    
    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let assetVideoIndicatorLabel: UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.textAlignment = .center
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        label.font = UIFont.systemFont(ofSize: 34)
        label.text = "▶"
        label.alpha = 0.9
        label.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        label.isEnabled = true
        return label
    }()
    
    var cellViewModel: AssetDetailCellViewModel?
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layout: do {
            contentView.addSubview(imageView)
            contentView.addSubview(assetVideoIndicatorLabel)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            assetVideoIndicatorLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                assetVideoIndicatorLabel.widthAnchor.constraint(equalTo: imageView.widthAnchor,
                                                                multiplier: 0.5),
                assetVideoIndicatorLabel.heightAnchor.constraint(equalTo: assetVideoIndicatorLabel.widthAnchor,
                                                                 multiplier: 1.0),
                assetVideoIndicatorLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                assetVideoIndicatorLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
            ])
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateSelection(isItemSelected: Bool) {
        if isItemSelected {
            imageView.layer.borderColor = configuration.selectionColor.cgColor
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
        
        let isVideo = (cellViewModel.asset.mediaType == .video)
        assetVideoIndicatorLabel.isHidden = !isVideo
        
        setDownloading(cellViewModel.isDownloading)
    }

    func setDownloading(_ isDownloading: Bool) {
        if isDownloading, spinner == nil {
            let spinner = UIActivityIndicatorView(style: .whiteLarge)
            contentView.addSubview(spinner)
            spinner.center = contentView.center
            spinner.startAnimating()
            self.spinner = spinner
        } else {
            spinner?.removeFromSuperview()
            spinner = nil
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        spinner?.removeFromSuperview()
        imageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        assetVideoIndicatorLabel.layer.cornerRadius = assetVideoIndicatorLabel.bounds.width / 2
    }
}

// MARK: AssetDetailCellViewModelDelegate

extension AssetDetailCell: AssetDetailCellViewModelDelegate {
    func cellViewModel(_ cellViewModel: AssetDetailCellViewModel, didFetchImage image: UIImage) {
        imageView.image = image
    }

    func cellViewModel(_ cellViewModel: AssetDetailCellViewModel, isDownloading: Bool) {
        setDownloading(isDownloading)
    }
}
