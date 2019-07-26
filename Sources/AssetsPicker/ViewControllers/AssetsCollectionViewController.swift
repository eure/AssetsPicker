//
//  PhotosPickerAssetsCollectionViewController.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/16.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit
import Photos

final class AssetsCollectionViewController: UIViewController {
    
    // MARK: Properties
    
    private let viewModel = AssetCollectionViewModel()
    private let selectionContainer: SelectionContainer<AssetDetailCellViewModel>

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let nib = AssetPickerConfiguration.shared.cellRegistrator.customAssetItemNibs[.assetCollection]?.0 {
            collectionView.register(nib, forCellWithReuseIdentifier: AssetPickerConfiguration.shared.cellRegistrator.cellIdentifier(forCellType: .assetCollection))
        } else {
            collectionView.register(
                AssetPickerConfiguration.shared.cellRegistrator.cellType(forCellType: .assetCollection),
                forCellWithReuseIdentifier: AssetPickerConfiguration.shared.cellRegistrator.cellIdentifier(forCellType: .assetCollection)
            )
        }
        
        collectionView.alwaysBounceVertical = false
        
        return collectionView
    }()
    
    init() {
        setupConfiguration: do {
            
            switch AssetPickerConfiguration.shared.selectionMode {
            case .single:
                self.selectionContainer = SelectionContainer<AssetDetailCellViewModel>(withSize: 1)
            case .multiple(let limit):
                self.selectionContainer = SelectionContainer<AssetDetailCellViewModel>(withSize: limit)
            }            
            super.init(nibName: nil, bundle: nil)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
}


extension AssetsCollectionViewController: UICollectionViewDataSource {
    @objc dynamic public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.displayItems.isEmpty ? 0 : 1
    }
    
    @objc dynamic public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.displayItems.count
    }
    
    @objc dynamic public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AssetPickerConfiguration.shared.cellRegistrator.cellIdentifier(forCellType: .assetCollection), for: indexPath)
        
        return cell
    }
}

extension AssetsCollectionViewController: UICollectionViewDelegate {
    @objc dynamic public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let assetCollection = viewModel.displayItems[indexPath.item].assetCollection
        let assetDetailController = AssetDetailViewController(withAssetCollection: assetCollection, andSelectionContainer: self.selectionContainer)
        navigationController?.pushViewController(assetDetailController, animated: true)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? AssetCollectionCellBindable else { return }
        
        let cellViewModel = viewModel.displayItems[indexPath.item]
        cell.bind(cellViewModel: cellViewModel)
    }
    
    @objc dynamic
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? AssetCollectionCellBindable else { return }
        
        cell.cellViewModel?.cancelLatestImageIfNeeded()
        cell.cellViewModel?.delegate = nil
        cell.cellViewModel = nil
    }
}

extension AssetsCollectionViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 80)
    }
    
    @objc dynamic public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    @objc dynamic public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
