//
//  PhotoPicker.PhotosPickerAssetsCollectionDelegate.Cell.ViewModel.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/18.
//  Copyright © 2018 eureka, Inc. All rights reserved.
//

#if os(iOS)
import Foundation
import Photos
import UIKit

public protocol AssetsCollectionCellViewModelDelegate: AnyObject {
    func cellViewModel(_ cellViewModel: AssetCollectionCellViewModel, didFetchImage image: UIImage)
    func cellViewModel(_ cellViewModel: AssetCollectionCellViewModel, didFetchNumberOfAssets numberOfAssets: String)
}

public final class AssetCollectionCellViewModel: ItemIdentifier {
    // MARK: Properties

    private let configuration: MosaiqueAssetPickerConfiguration
    public weak var delegate: AssetsCollectionCellViewModelDelegate?
    public var assetCollection: PHAssetCollection
    private var imageRequestId: PHImageRequestID?

    // MARK: Lifecycle

    init(assetCollection: PHAssetCollection, configuration: MosaiqueAssetPickerConfiguration) {
        self.assetCollection = assetCollection
        self.configuration = configuration
    }

    // MARK: ItemIdentifier

    public var identifier: String {
        assetCollection.localIdentifier
    }

    // MARK: Core

    public func cancelLatestImageIfNeeded() {
        guard let imageRequestId = imageRequestId else { return }
        PHCachingImageManager.default().cancelImageRequest(imageRequestId)
        self.imageRequestId = nil
    }

    public func fetchLatestImage() {
        imageRequestId = nil

        let firstAssetFetchOptions: PHFetchOptions = {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false),
            ]

            if !configuration.supportOnlyMediaTypes.isEmpty {
                let predicates = configuration.supportOnlyMediaTypes.map { NSPredicate(format: "mediaType = %d", $0.rawValue) }
                fetchOptions.predicate = NSCompoundPredicate(type: .or, subpredicates: predicates)
            }

            return fetchOptions
        }()

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }

            let result = PHAsset.fetchAssets(
                in: self.assetCollection,
                options: firstAssetFetchOptions
            )

            DispatchQueue.main.async {
                self.delegate?.cellViewModel(self, didFetchNumberOfAssets: result.count.description)
            }

            guard let firstAsset = result.firstObject else {
                return
            }

            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic
            options.isNetworkAccessAllowed = true
            options.version = .current
            options.resizeMode = .fast

            let imageManager = PHCachingImageManager.default()

            self.imageRequestId = imageManager.requestImage(
                for: firstAsset,
                targetSize: CGSize(width: 250, height: 250),
                contentMode: .aspectFill,
                options: options
            ) { [weak self] image, _ in
                guard let self = self else { return }
                if let image = image {
                    DispatchQueue.main.async {
                        self.delegate?.cellViewModel(self, didFetchImage: image)
                    }
                }
            }
        }
    }
}
#endif
