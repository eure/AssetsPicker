//
//  PhotosPickerAssetsCollectionViewController.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/16.
//  Copyright © 2018 eureka, Inc. All rights reserved.
//

import Photos
import UIKit

protocol AssetCollectionViewModelDelegate: AnyObject {
    func updatedCollections()
}

public final class AssetCollectionViewModel: NSObject {
    // MARK: Lifecycle

    private(set) var displayItems: [AssetCollectionCellViewModel] = [] {
        didSet {
            delegate?.updatedCollections()
        }
    }

    private let configuration: MosaiqueAssetPickerConfiguration
    private let lock = NSLock()
    private var assetCollectionsFetchResults = [PHFetchResult<PHAssetCollection>]()
    private var collectionsFetchResults = [PHFetchResult<PHCollection>]()
    weak var delegate: AssetCollectionViewModelDelegate?

    init(configuration: MosaiqueAssetPickerConfiguration) {
        self.configuration = configuration
        super.init()
        PHPhotoLibrary.shared().register(self)
        fetchCollections()
    }

    // MARK: Core

    private func fetchCollections() {
        DispatchQueue.global(qos: .userInteractive).async {
            self.lock.lock()
            defer { self.lock.unlock() }
            self.assetCollectionsFetchResults.removeAll()
            self.collectionsFetchResults.removeAll()
            var assetCollections: [PHAssetCollection] = []
            do {
                let library = PHAssetCollection.fetchAssetCollections(
                    with: .smartAlbum,
                    subtype: .smartAlbumUserLibrary,
                    options: nil
                )
                self.assetCollectionsFetchResults.append(library)
                assetCollections += library.toArray()
            }

            do {
                let library = PHAssetCollection.fetchAssetCollections(
                    with: .smartAlbum,
                    subtype: .smartAlbumFavorites,
                    options: nil
                )
                self.assetCollectionsFetchResults.append(library)
                assetCollections += library.toArray()
            }

            do {
                let library = PHAssetCollection.fetchAssetCollections(
                    with: .smartAlbum,
                    subtype: .smartAlbumScreenshots,
                    options: nil
                )
                self.assetCollectionsFetchResults.append(library)
                assetCollections += library.toArray()
            }

            do {
                let library = PHCollection.fetchTopLevelUserCollections(with: nil)
                self.collectionsFetchResults.append(library)

                library.enumerateObjects { collection, _, _ in
                    if let assetCollection = collection as? PHAssetCollection {
                        assetCollections.append(assetCollection)
                    }
                }
            }

            do {
                let library = PHAssetCollection.fetchAssetCollections(
                    with: .album,
                    subtype: .albumCloudShared,
                    options: nil
                )
                self.assetCollectionsFetchResults.append(library)

                assetCollections += library.toArray()
            }

            self.displayItems = assetCollections
                .filter { self.assetCount(collection: $0) != 0 }
                .map { AssetCollectionCellViewModel(assetCollection: $0, configuration: self.configuration) }
        }
    }

    func assetCount(collection: PHAssetCollection) -> Int {
        let fetchOptions = PHFetchOptions()

        if !configuration.supportOnlyMediaTypes.isEmpty {
            let predicates = configuration.supportOnlyMediaTypes.map { NSPredicate(format: "mediaType = %d", $0.rawValue) }
            fetchOptions.predicate = NSCompoundPredicate(type: .or, subpredicates: predicates)
        }
        let result = PHAsset.fetchAssets(in: collection, options: fetchOptions)
        return result.count
    }
}

extension AssetCollectionViewModel: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        // assuming complexity for collections is low, reload everything
        lock.exec {
            for collection in self.collectionsFetchResults where changeInstance.changeDetails(for: collection) != nil {
                self.fetchCollections()
                return
            }
            for collection in self.assetCollectionsFetchResults where changeInstance.changeDetails(for: collection) != nil {
                self.fetchCollections()
                return
            }
        }
    }
}

extension PHFetchResult where ObjectType == PHAssetCollection {
    fileprivate func toArray() -> [PHAssetCollection] {
        var array: [PHAssetCollection] = []
        array.reserveCapacity(count)
        enumerateObjects { asset, _, _ in
            array.append(asset)
        }

        return array
    }
}
