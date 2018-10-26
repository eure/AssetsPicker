//
//  PhotosPicker.AssetDetailViewController.CellViewModel.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/19.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import Photos

protocol AssetDetailCellViewModelDelegate: class {
    func cellViewModel(_ cellViewModel: PhotosPicker.AssetDetailViewController.CellViewModel, didFetchImage image: UIImage)
}

extension PhotosPicker.AssetDetailViewController {
    final class CellViewModel: ItemIdentifier {
        
        // MARK: Inner
        
        enum Selection : Equatable {
            
            case notSelected
            case selected(number: Int)
        }
        
        // MARK: Properties
        
        weak var delegate: AssetDetailCellViewModelDelegate?
        private let asset: PHAsset
        private let imageManager: PHCachingImageManager
        private let selectionContainer: SelectionContainer<CellViewModel>
        private var imageRequestId: PHImageRequestID?

        // MARK: Lifecycle
        
        init(
            asset: PHAsset,
            imageManager: PHCachingImageManager,
            selectionContainer: SelectionContainer<CellViewModel>
            ) {
            
            self.asset = asset
            self.imageManager = imageManager
            self.selectionContainer = selectionContainer
        }
        
        func selectionStatus() -> Selection {
            var selectionState = Selection.notSelected
            
            if let index = self.selectionContainer.selectedItems.index(where: { $0.identifier == asset.localIdentifier }) {
                selectionState = Selection.selected(number: index + 1)
            }
            
            return selectionState
        }
        
        func cancelImageIfNeeded() {
            guard let imageRequestId = imageRequestId else { return }
            
            PHCachingImageManager.default().cancelImageRequest(imageRequestId)
            self.imageRequestId = nil
        }
        
        func fetchPreviewImage() {
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic
            options.isNetworkAccessAllowed = true
            options.version = .current
            options.resizeMode = .fast
            
            self.imageRequestId = imageManager.requestImage(
                for: asset,
                targetSize: CGSize(width: 360, height: 360),
                contentMode: .aspectFill,
                options: options) { [weak self] (image, userInfo) in
                    if let image = image {
                        guard let `self` = self else { return }
                        self.delegate?.cellViewModel(self, didFetchImage: image)
                    } else {
                        print("cannot download image for id = \(self?.asset.localIdentifier)")
                    }
            }
        }
        
        func download(onNext: @escaping ((UIImage?) -> ())) {
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.version = .current
            options.resizeMode = .exact
            
            self.imageRequestId = imageManager.requestImage(
                for: asset,
                targetSize: CGSize(width: 1920, height: 1920),
                contentMode: .default,
                options: options) { (image, userInfo) in
                    onNext(image)
            }
        }
        
        // MARK: ItemIdentifier
        
        var identifier: String {
            return asset.localIdentifier
        }
    }
}
