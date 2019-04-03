//
//  PhotosPickerAssetsCollectionViewController.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/16.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import UIKit
import Photos

public final class AssetCollectionViewModel {
    
    // MARK: Lifecycle
    
    var cameraRollAssetCollection: PHAssetCollection?
    fileprivate(set) var displayItems: [AssetCollectionCellViewModel] = []
    
    // MARK: Lifecycle
    
    func loadAssets() {
        self.cameraRollAssetCollection = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .smartAlbumUserLibrary,
            options: nil
            )
            .firstObject
    }
    
    // MARK: Core
    
    func fetchAssetsCollections(onNext: @escaping (() -> ())) {
        DispatchQueue.global(qos: .userInteractive).async {
            
            var assetCollections: [PHAssetCollection] = []
            
            do {
                let library = PHAssetCollection.fetchAssetCollections(
                    with: .smartAlbum,
                    subtype: .smartAlbumUserLibrary,
                    options: nil
                )
                
                assetCollections += library.toArray()
            }
            
            do {
                let library = PHAssetCollection.fetchAssetCollections(
                    with: .smartAlbum,
                    subtype: .smartAlbumFavorites,
                    options: nil
                )
                
                assetCollections += library.toArray()
            }
            
            do {
                let library = PHAssetCollection.fetchAssetCollections(
                    with: .smartAlbum,
                    subtype: .smartAlbumScreenshots,
                    options: nil
                )
                
                assetCollections += library.toArray()
            }
            
            do {
                let library = PHCollection.fetchTopLevelUserCollections(with: nil)
                
                library.enumerateObjects { (collection, _, _) in
                    if let assetCollection = collection as? PHAssetCollection {
                        assetCollections.append(assetCollection)
                    }
                }
            }
            
            self.displayItems = assetCollections.map(AssetCollectionCellViewModel.init(assetCollection:))
            onNext()
        }
    }
}


extension PHFetchResult where ObjectType == PHAssetCollection {
    
    fileprivate func toArray() -> [PHAssetCollection] {
        var array: [PHAssetCollection] = []
        array.reserveCapacity(count)
        self.enumerateObjects { (asset, _, _) in
            array.append(asset)
        }
        
        return array
    }
}
