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
    
    public class AssetsCollectionViewController: BaseViewController<AssetCollectionViewModel>,
        UICollectionViewDataSource,
        UICollectionViewDelegate,
        UICollectionViewDelegateFlowLayout {
        
        // MARK: Properties
        
        weak var delegate: PhotosPickerAssetsCollectionDelegate?

        private lazy var collectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 1
            layout.minimumInteritemSpacing = 1
        
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.backgroundColor = .white
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(Cell.self, forCellWithReuseIdentifier: String(describing: Cell.self))
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
                collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            }
            
            if PHPhotoLibrary.authorizationStatus() == .denied {
                print("Permission denied for accessing to photos.")
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
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PhotosPicker.AssetsCollectionViewController.Cell.self), for: indexPath) as? PhotosPicker.AssetsCollectionViewController.Cell else {
                return UICollectionViewCell()
            }
            
            return cell
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
            guard let cell = cell as? PhotosPicker.AssetsCollectionViewController.Cell else { return }
            
            let cellViewModel = viewModel.displayItems[indexPath.item]
            cell.bind(cellViewModel: cellViewModel)
        }
    
        @objc dynamic public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let assetCollection = viewModel.displayItems[indexPath.item].assetCollection
            delegate?.photoPicker(self, didSelectAsset: assetCollection)
        }
    }
}
