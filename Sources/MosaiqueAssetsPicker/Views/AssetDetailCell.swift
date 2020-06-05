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

    // MARK: Properties
    private var spinner: UIActivityIndicatorView?

    var selectionColor: UIColor = .clear {
        didSet {
            updateSelection(isItemSelected: isSelected)
        }
    }

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

    private lazy var assetVideoGradientView: GradiantView = {
        GradiantView(
            colors:
            [
                UIColor.black.withAlphaComponent(0.5).cgColor,
                UIColor.clear.cgColor,
            ],
            startPoint: CGPoint(x: 1, y: 1),
            endPoint: CGPoint(x: 0, y: 0),
            type: .radial,
            locations: [0, 1]
        )
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
                assetVideoGradientView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                assetVideoGradientView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                assetVideoGradientView.heightAnchor.constraint(equalTo: assetVideoLabel.heightAnchor, multiplier: 2),
                assetVideoGradientView.widthAnchor.constraint(equalTo: assetVideoLabel.widthAnchor, multiplier: 1.8),
                assetVideoLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 4),
                assetVideoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4),
                assetVideoLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
            ])
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateSelection(isItemSelected: Bool) {
        if isItemSelected {
            imageView.layer.borderColor = selectionColor.cgColor
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
        assetVideoGradientView.isHidden = !isVideo
        if isVideo {
            let timeString = timeFormatter.string(from: cellViewModel.asset.duration) ?? "00:00"
            assetVideoLabel.text = timeString
        }
        
        setDownloading(cellViewModel.isDownloading)
    }

    func setDownloading(_ isDownloading: Bool) {
        if isDownloading {

            let spinner = self.spinner ?? {
                let spinner = UIActivityIndicatorView(style: .whiteLarge)
                self.spinner = spinner
                return spinner
                }()

            if spinner.superview != contentView {
                contentView.addSubview(spinner)
            }

            // TODO: It might be good to Use AutoLayout
            spinner.center = contentView.center
            spinner.startAnimating()
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
