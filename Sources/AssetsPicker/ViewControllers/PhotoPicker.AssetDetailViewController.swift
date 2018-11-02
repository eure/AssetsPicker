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
        var headerSizeCalculator: ViewSizeCalculator<UIView>?
        
        private let collectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 1
            layout.minimumInteritemSpacing = 1
            layout.sectionHeadersPinToVisibleBounds = Configuration.shared.isHeaderFloating
            
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.backgroundColor = .white
            collectionView.allowsSelection = true
            
            switch PhotosPicker.Configuration.shared.selectionMode {
            case .single:
                collectionView.allowsMultipleSelection = false
            case .multiple(let size):
                collectionView.allowsMultipleSelection = size > 1
            }
            collectionView.register(
                PhotosPicker.Configuration.shared.cellRegistrator.cellType(forCellType: .asset),
                forCellWithReuseIdentifier: PhotosPicker.Configuration.shared.cellRegistrator.cellIdentifier(forCellType: .asset)
            )

            if Configuration.shared.headerView != nil {
                collectionView.register(HeaderContainerView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: PhotosPicker.AssetDetailViewController.HeaderContainerView.self))
            }
            
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
                    doneBarButtonItem.isEnabled = false
                    parentController.navigationItem.rightBarButtonItem = doneBarButtonItem
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
                fatalError("Permission denied for accessing to photos.")
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PhotosPicker.Configuration.shared.cellRegistrator.cellIdentifier(forCellType: .asset)), for: indexPath)
            
            return cell
        }
        
        @objc dynamic public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            if kind == UICollectionView.elementKindSectionHeader {
                guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: HeaderContainerView.self), for: indexPath) as? HeaderContainerView else { return UICollectionReusableView() }
                
                guard let headerView = Configuration.shared.headerView else { fatalError() }
                view.set(view: headerView)
                
                return view
            } else {
                fatalError()
            }
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
            guard let cellProtocol = cell as? AssetPickAssetCellCustomization else { return }
            let cellViewModel = viewModel.cellModel(at: indexPath.item)
            cellProtocol.bind(cellViewModel: cellViewModel)
            
            if PhotosPicker.Configuration.shared.disableOnLibraryScrollAnimation == false {
                cell.alpha = 0.5
                
                UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
                    cell.alpha = 1
                }, completion: nil)
            }
        }
        
        @objc dynamic public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            guard let cell = collectionView.cellForItem(at: indexPath) else { return }
            guard let cellViewModel = (cell as? AssetPickAssetCellCustomization)?.cellViewModel else { return }

            self.viewModel.toggle(item: cellViewModel)

            if let parentController = parent {
                parentController.navigationItem.rightBarButtonItem?.isEnabled = !viewModel.selectionContainer.isEmpty
            }
        }
        
        public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
            guard let cell = collectionView.cellForItem(at: indexPath) else { return }
            guard let cellViewModel = (cell as? AssetPickAssetCellCustomization)?.cellViewModel else { return }
            
            self.viewModel.toggle(item: cellViewModel)
            
            if let parentController = parent {
                parentController.navigationItem.rightBarButtonItem?.isEnabled = !viewModel.selectionContainer.isEmpty
            }
        }
        
        @objc dynamic public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            guard let haederView = Configuration.shared.headerView else {
                return .zero
            }
            
            if headerSizeCalculator == nil {
                headerSizeCalculator = ViewSizeCalculator(sourceView: haederView, calculateTargetView: { $0 })
            }
            
            return headerSizeCalculator?.calculate(width: collectionView.bounds.width, height: nil, cacheKey: nil, closure: { _ in }) ?? .zero
        }
    }
    
    public final class ViewModel {
        
        // MARK: Properties
        
        private let imageManager = PHCachingImageManager()
        private(set) var assetCollection: PHAssetCollection
        private(set) var selectionContainer: SelectionContainer<PhotosPicker.AssetDetailViewController.CellViewModel>
        private(set) var displayItems: PHFetchResult<PHAsset>

        // MARK: Lifecycle
        
        init(assetCollection: PHAssetCollection, selectionContainer: SelectionContainer<PhotosPicker.AssetDetailViewController.CellViewModel>) {
            self.assetCollection = assetCollection
            self.selectionContainer = selectionContainer
            self.displayItems = PHFetchResult<PHAsset>()
        }
        
        func fetchPhotos(onNext: @escaping (() -> ())) {
            DispatchQueue.global(qos: .userInteractive).async {
                
                let fetchOptions = PHFetchOptions()
                
                if !PhotosPicker.Configuration.shared.supportOnlyMediaType.isEmpty {
                    let predicates = PhotosPicker.Configuration.shared.supportOnlyMediaType.map { NSPredicate(format: "mediaType = %d", $0.rawValue) }
                    fetchOptions.predicate = NSCompoundPredicate(type: .or, subpredicates: predicates)
                }
                
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

            for cellModel in selectionContainer.selectedItems {
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
            if case .notSelected = item.selectionStatus() {
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
