//
//  PhotoPicker.AssetDetailViewController.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/18.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import Photos

protocol PhotosPickerAssetDetailDelegate: class {
    func photoPicker(_ pickerController: PhotosPicker.AssetDetailViewController, didPickImages images: [UIImage])
}

extension PhotosPicker {
    
    public final class AssetDetailViewController: BaseViewController<ViewModel>,
        UICollectionViewDelegate,
        UICollectionViewDataSource,
        UICollectionViewDelegateFlowLayout {
        
        // MARK: Properties
        
        weak var delegate: PhotosPickerAssetDetailDelegate?

        private let collectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 1
            layout.minimumInteritemSpacing = 1
            layout.estimatedItemSize = CGSize(width: 120, height: 120)
            
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.backgroundColor = .white
            collectionView.register(PhotosPicker.AssetDetailViewController.Cell.self, forCellWithReuseIdentifier:  String(describing: PhotosPicker.AssetDetailViewController.Cell.self))
            return collectionView
        }()
        
        private let gridCount: Int = PhotosPicker.Configuration.shared.numberOfItemsInRow
        
        // MARK: Lifecycle
        
        public override func viewDidLoad() {
            super.viewDidLoad()
            
            view.backgroundColor = .white

            setupView: do {
                view.addSubview(collectionView)
                collectionView.delegate = self
                collectionView.dataSource = self
            }
            setupDoneButton: do {
                if let parentController = parent {
                    let doneBarButtonItem = UIBarButtonItem(title: PhotosPicker.Configuration.shared.localize.done, style: .done, target: self, action: #selector(didPickAssets(sender:)))
                    doneBarButtonItem.isEnabled = false
                    doneBarButtonItem.tintColor = PhotosPicker.Configuration.shared.tintColor
                    parentController.navigationItem.rightBarButtonItem = doneBarButtonItem
                    parentController.navigationItem.rightBarButtonItem?.enabledLink.bind(data: viewModel.isNotEmptySelectionContainer)
                }
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
            
            loadPhotos()
        }
        
        func loadPhotos() {
            viewModel.fetchPhotos { [weak self] in
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        }
        // MARK: User Interaction

        @IBAction func didPickAssets(sender: Any) {
            // Display loader
            viewModel.downloadSelectedCells { [weak self] images in
                guard let `self` = self else { return }
                // stop loader
                self.delegate?.photoPicker(self, didPickImages: images)
            }
        }
        
        // MARK: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
        
        @objc dynamic public func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        
        @objc dynamic public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return viewModel.displayItems.count
        }
        
        @objc dynamic public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PhotosPicker.AssetDetailViewController.Cell.self), for: indexPath) as? PhotosPicker.AssetDetailViewController.Cell else {
                return UICollectionViewCell()
            }
            
            return cell
        }
        
        @objc dynamic public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            func CalculateFittingGridSize(maxWidth: CGFloat, numberOfItemsInRow: Int, margin: CGFloat, index: Int) -> CGSize {
                let totalMargin: CGFloat = margin * CGFloat(numberOfItemsInRow - 1)
                let actualWidth: CGFloat = maxWidth - totalMargin
                let width: CGFloat = CGFloat(floorf(Float(actualWidth) / Float(numberOfItemsInRow)))
                let extraWidth: CGFloat = actualWidth - (width * CGFloat(numberOfItemsInRow))
                
                if index % numberOfItemsInRow == 0 || index % numberOfItemsInRow == (numberOfItemsInRow - 1) {
                    return CGSize(width: width + extraWidth / 2.0, height: width)
                } else {
                    return CGSize(width: width, height: width)
                }
            }
            
            let size = CalculateFittingGridSize(maxWidth: collectionView.bounds.width, numberOfItemsInRow: gridCount, margin: 1, index: (indexPath as NSIndexPath).item)
            
            return size
        }
        
        public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            guard let cell = cell as? PhotosPicker.AssetDetailViewController.Cell else { return }
            
            let cellViewModel = viewModel.cellModel(at: indexPath.item)
            cell.bind(cellViewModel: cellViewModel)
        }
        
        @objc dynamic public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            guard let cell = collectionView.cellForItem(at: indexPath) as? PhotosPicker.AssetDetailViewController.Cell else { return }
            
            guard let cellModel = cell.cellViewModel else { return }
            
            self.viewModel.toggle(item: cellModel)
        }
    }
    
    public final class ViewModel {
        
        // MARK: Properties
        
        private(set) var isNotEmptySelectionContainer: Observable<Bool> = Observable<Bool>(true)
        private let imageManager = PHCachingImageManager()
        private(set) var assetCollection: PHAssetCollection
        private(set) var selectionContainer: SelectionContainer<PhotosPicker.AssetDetailViewController.CellViewModel>
        private(set) var displayItems: PHFetchResult<PHAsset>
        private var link: Link<[PhotosPicker.AssetDetailViewController.CellViewModel]>?

        // MARK: Lifecycle
        
        init(assetCollection: PHAssetCollection, selectionContainer: SelectionContainer<PhotosPicker.AssetDetailViewController.CellViewModel>) {
            self.assetCollection = assetCollection
            self.selectionContainer = selectionContainer
            self.displayItems = PHFetchResult<PHAsset>()
            
            link = Link<[PhotosPicker.AssetDetailViewController.CellViewModel]>() { [weak self] selectedItems in
                self?.isNotEmptySelectionContainer.value = !selectedItems.isEmpty
            }
            
            link?.bind(data: selectionContainer.selectedItems)
        }
        
        func fetchPhotos(onNext: @escaping (() -> ())) {
            DispatchQueue.global(qos: .userInteractive).async {
                
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                
                let result = PHAsset.fetchAssets(
                    in: self.assetCollection,
                    options: fetchOptions
                )
                
                self.displayItems = result
                onNext()
            }
        }
        
        func downloadSelectedCells(onNext: @escaping (([UIImage]) -> Void)) {
            let dispatchGroup = DispatchGroup()
            var images: [UIImage] = []

            for cellModel in selectionContainer.selectedItems.value {
                dispatchGroup.enter()
                
                cellModel.download(onNext: { image in
                    DispatchQueue.main.async {
                        if let image = image {
                            images.append(image)
                        }
                        dispatchGroup.leave()
                    }
                })
            }
            
            dispatchGroup.notify(queue: DispatchQueue.main) {
                onNext(images)
            }
        }
        
        func reset(withAssetCollection assetCollection: PHAssetCollection) {
            self.assetCollection = assetCollection
            self.selectionContainer.purge()
        }
        
        func cellModel(at index: Int) -> PhotosPicker.AssetDetailViewController.CellViewModel {
            
            let asset = displayItems.object(at: index)
            
            if let cellModel = selectionContainer.item(for: asset.localIdentifier) {
                return cellModel
            }
            
            let cellModel = makeCellModel(from: asset)
            
            return cellModel
        }
        
        private func makeCellModel(from asset: PHAsset) -> PhotosPicker.AssetDetailViewController.CellViewModel {
            
            let cellModel = PhotosPicker.AssetDetailViewController.CellViewModel(
                asset: asset,
                imageManager: imageManager,
                selectionContainer: selectionContainer
            )
                        
            return cellModel
        }
        
        func toggle(item: PhotosPicker.AssetDetailViewController.CellViewModel) {
            if case .notSelected = item.selection.value {
                select(item: item)
            } else {
                unselect(item: item)
            }
        }
        
        private func select(item: PhotosPicker.AssetDetailViewController.CellViewModel) {
            selectionContainer.append(item: item, removeFirstIfAlreadyFilled: selectionContainer.size == 1)
        }
        
        private func unselect(item: PhotosPicker.AssetDetailViewController.CellViewModel) {
            selectionContainer.remove(item: item)
        }
    }
}

class ImageDownloadOperation: Operation {
    
    let cellViewModel: PhotosPicker.AssetDetailViewController.CellViewModel
    
    init(cellViewModel: PhotosPicker.AssetDetailViewController.CellViewModel) {
        self.cellViewModel = cellViewModel
    }
    override func start() {
        cellViewModel.download { (image) in
            
        }
    }
}