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

protocol PhotosPickerAssetsCollectionDelegate: class {
    func photoPicker(_ selectAssetController: PhotosPicker.AssetsCollectionViewController, didSelectAsset asset: PHAssetCollection)
}

extension PhotosPicker {
    
    public class AssetsCollectionViewController: UIViewController,
        UICollectionViewDataSource,
        UICollectionViewDelegate,
        UICollectionViewDelegateFlowLayout {
        
        // MARK: Properties
        
        private let viewModel = AssetCollectionViewModel()
        weak var delegate: PhotosPickerAssetsCollectionDelegate?

        private lazy var collectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 1
            layout.minimumInteritemSpacing = 1
        
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.backgroundColor = .white
            collectionView.delegate = self
            collectionView.dataSource = self
            
            if let nib = PhotosPicker.Configuration.shared.cellRegistrator.customAssetItemNibs[.assetCollection]?.0 {
                collectionView.register(nib, forCellWithReuseIdentifier: PhotosPicker.Configuration.shared.cellRegistrator.cellIdentifier(forCellType: .assetCollection))
            } else {
                collectionView.register(
                    PhotosPicker.Configuration.shared.cellRegistrator.cellType(forCellType: .assetCollection),
                    forCellWithReuseIdentifier: PhotosPicker.Configuration.shared.cellRegistrator.cellIdentifier(forCellType: .assetCollection)
                )
            }
            
            collectionView.alwaysBounceVertical = false
            
            return collectionView
        }()
        
        // MARK: Lifecycle
        
        public override func viewDidLoad() {
            super.viewDidLoad()
            
            setupView: do {
                view.addSubview(collectionView)
            }
            layout: do {
                guard let view = view else { return }
                collectionView.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    collectionView.topAnchor.constraint(equalTo: view.topAnchor),
                    collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
            }
            
            if PHPhotoLibrary.authorizationStatus() == .denied {
                fatalError("Permission denied for accessing to photos.")
            }
            
            viewModel.fetchAssetsCollections() {
                DispatchQueue.main.async(execute: { [weak self] in
                    self?.collectionView.reloadData()
                })
            }
        }
    
        // MARK: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
    
        @objc dynamic public func numberOfSections(in collectionView: UICollectionView) -> Int {
            return viewModel.displayItems.isEmpty ? 0 : 1
        }
    
        @objc dynamic public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return viewModel.displayItems.count
        }
    
        @objc dynamic public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotosPicker.Configuration.shared.cellRegistrator.cellIdentifier(forCellType: .assetCollection), for: indexPath)
            
            return cell
        }
        
        @objc dynamic
        public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            guard let cell = cell as? AssetPickAssetCollectionCellCustomization else { return }

            cell.cellViewModel?.cancelLatestImageIfNeeded()
            cell.cellViewModel?.delegate = nil
            cell.cellViewModel = nil
        }
    
        @objc dynamic public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        }
    
        @objc dynamic public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 5
        }
        
        public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: collectionView.bounds.width, height: 80)
        }
        
        public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            guard let cell = cell as? AssetPickAssetCollectionCellCustomization else { return }

            let cellViewModel = viewModel.displayItems[indexPath.item]
            cell.bind(cellViewModel: cellViewModel)
        }
    
        @objc dynamic public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let assetCollection = viewModel.displayItems[indexPath.item].assetCollection
            delegate?.photoPicker(self, didSelectAsset: assetCollection)
        }
    }
}
