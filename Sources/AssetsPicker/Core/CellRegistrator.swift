//
//  CellRegistrator.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/30.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import UIKit

public enum CellType: String {
    case assetCollection, asset
}

public protocol PickerCustomization {}

public protocol AssetPickAssetCellCustomization: PickerCustomization, AssetDetailCellViewModelDelegate {
    var cellViewModel: PhotosPicker.AssetDetailViewController.CellViewModel? { get set }
    func bind(cellViewModel: PhotosPicker.AssetDetailViewController.CellViewModel)
}

public protocol AssetPickAssetCollectionCellCustomization: PickerCustomization, AssetsCollectionCellViewModelDelegate {
    var cellViewModel: PhotosPicker.AssetsCollectionViewController.CellViewModel? { get set }
    func bind(cellViewModel: PhotosPicker.AssetsCollectionViewController.CellViewModel)
}

public class CellRegistrator {
    
    // MARK: Properties
    
    var customAssetItemClasses: [CellType: (UICollectionViewCell.Type, String)] = [:]
    var customAssetItemNibs: [CellType: (UINib, String)] = [:]

    var defaultAssetItemClasses: [CellType: (UICollectionViewCell.Type, String)] = [
        .asset: (PhotosPicker.AssetDetailViewController.Cell.self, String(describing: PhotosPicker.AssetDetailViewController.Cell.self)),
        .assetCollection: (PhotosPicker.AssetsCollectionViewController.Cell.self, String(describing: PhotosPicker.AssetsCollectionViewController.Cell.self))
    ]
    
    func cellType(forCellType cellType: CellType) -> UICollectionViewCell.Type {
        return customAssetItemClasses[cellType]?.0 ?? defaultAssetItemClasses[cellType]?.0 ?? UICollectionViewCell.self
    }
    
    func cellIdentifier(forCellType cellType: CellType) -> String {
        return customAssetItemClasses[cellType]?.1 ?? defaultAssetItemClasses[cellType]?.1 ?? "Cell"
    }

    // MARK: Core
    
    public func register(nib: UINib, forCellType cellType: CellType) {
        let nibIdentifier = String(describing: nib.self)
        customAssetItemNibs[cellType] = (nib, nibIdentifier)
    }
    
    public func register<T: UICollectionViewCell>(cellClass: T.Type, forCellType cellType: CellType) where T: PickerCustomization {
        let cellIdentifier = String(describing: T.self)
        customAssetItemClasses[cellType] = (cellClass, cellIdentifier)
    }
}
