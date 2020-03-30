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
    private let gradientLayer = CAGradientLayer()
    
    private lazy var timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.second, .minute]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
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
    
    private lazy var assetVideoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    private lazy var assetVideoGradientView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.6).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.2, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        return view
    }()
    
    var cellViewModel: AssetDetailCellViewModel?
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layout: do {
            contentView.addSubview(imageView)
            contentView.addSubview(assetVideoGradientView)
            contentView.addSubview(assetVideoLabel)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            assetVideoGradientView.translatesAutoresizingMaskIntoConstraints = false
            assetVideoLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                assetVideoGradientView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                assetVideoGradientView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                assetVideoGradientView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                assetVideoGradientView.heightAnchor.constraint(equalToConstant: 30),
                assetVideoLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 4),
                assetVideoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4),
                assetVideoLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
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
        assetVideoLabel.isHidden = !isVideo
        if isVideo {
            let timeString = timeFormatter.string(from: cellViewModel.asset.duration) ?? "00:00"
            assetVideoLabel.text = timeString
        }
        
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
        gradientLayer.frame = assetVideoGradientView.bounds
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
