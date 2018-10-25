//
//  PhotoPicker.PhotosPickerAssetsCollectionDelegate.Cell.ViewModel.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/18.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import UIKit
import Photos

extension PhotosPicker.AssetsCollectionViewController {
    
    public final class CellViewModel: ItemIdentifier {

        // MARK: Properties
        
        private(set) var assetCollection: PHAssetCollection
        private(set) var assetCount: Observable<String?> =  Observable<String?>(nil)
        private(set) var firstAssetInCollection: Observable<UIImage?> = Observable<UIImage?>(nil)
        private var imageRequestId: PHImageRequestID?
        
        // MARK: Lifecycle
        
        init(assetCollection: PHAssetCollection) {
            self.assetCollection = assetCollection
        }
        
        init(withAssetCollection assetCollection: PHAssetCollection) {
            self.assetCollection = assetCollection
        }
        
        // MARK: ItemIdentifier
        
        public var identifier: String {
            return assetCollection.localIdentifier
        }
        
        // MARK: Core
        
        func cancelLatestImageIfNeeded() {
            guard let imageRequestId = imageRequestId else { return }
            PHCachingImageManager.default().cancelImageRequest(imageRequestId)
            self.imageRequestId = nil
        }
        
        func fetchLatestImage() {
            imageRequestId = nil
            
            let queue = DispatchQueue.init(label: "jp.eure.pairs.photo")
            let firstAssetFetchOptions: PHFetchOptions = {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [
                    NSSortDescriptor(key: "creationDate", ascending: false),
                ]
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                
                return fetchOptions
            }()
            let currentAssetCollection = self.assetCollection
            
            queue.async(execute: { [weak self] in
                let result = PHAsset.fetchAssets(
                    in: currentAssetCollection,
                    options: firstAssetFetchOptions
                )
                
                self?.assetCount.value = result.count.description
                
                guard let firstAsset = result.firstObject else {
                    return
                }
                
                let options = PHImageRequestOptions()
                options.deliveryMode = .opportunistic
                options.isNetworkAccessAllowed = true
                options.version = .current
                options.resizeMode = .fast
                
                let imageManager = PHCachingImageManager.default()
                self?.imageRequestId = imageManager.requestImage(
                    for: firstAsset,
                    targetSize: CGSize(width: 250, height: 250),
                    contentMode: .aspectFill,
                    options: options) { [weak self] (image, userInfo) in
                        if let image = image {
                            self?.firstAssetInCollection.value = image
                        }
                }
            })
        }
    }
}
