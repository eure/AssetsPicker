//
//  PhotoPicker.AssetDetailViewController.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/18.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import Photos

public final class AssetDetailViewController: UIViewController {
    // MARK: Properties
    
    let viewModel: ViewModel
    var headerSizeCalculator: ViewSizeCalculator<UIView>?
    private var collectionView: UICollectionView!
    let configuration: AssetPickerConfiguration
    
    private var gridCount: Int {
        return viewModel.configuration.numberOfItemsPerRow
    }
    
    // MARK: Lifecycle
    
    init(withAssetCollection assetCollection: PHAssetCollection, andSelectionContainer selectionContainer: SelectionContainer<AssetDetailCellViewModel>, configuration: AssetPickerConfiguration) {
        self.viewModel = ViewModel(
            assetCollection: assetCollection,
            selectionContainer: selectionContainer,
            configuration: configuration
        )
        
        self.configuration = configuration
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView: do {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 1
            layout.minimumInteritemSpacing = 1
            layout.sectionHeadersPinToVisibleBounds = viewModel.configuration.isHeaderFloating

            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.backgroundColor = .white
            collectionView.allowsSelection = true

            switch viewModel.configuration.selectionMode {
            case .single:
                collectionView.allowsMultipleSelection = false
            case .multiple(let size):
                collectionView.allowsMultipleSelection = size > 1
            }

            if let nib = viewModel.configuration.cellRegistrator.customAssetItemNibs[.asset]?.0 {
                collectionView.register(nib, forCellWithReuseIdentifier: viewModel.configuration.cellRegistrator.cellIdentifier(forCellType: .asset))
            } else {
                collectionView.register(
                    viewModel.configuration.cellRegistrator.cellType(forCellType: .asset),
                    forCellWithReuseIdentifier: viewModel.configuration.cellRegistrator.cellIdentifier(forCellType: .asset)
                )
            }

            if viewModel.configuration.headerView != nil {
                collectionView.register(AssetDetailHeaderContainerView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: AssetDetailHeaderContainerView.self))
            }
            self.collectionView = collectionView

            view.addSubview(collectionView)
            collectionView.delegate = self
            collectionView.dataSource = self
            let doneBarButtonItem = UIBarButtonItem(title: viewModel.configuration.localize.done, style: .done, target: self, action: #selector(didPickAssets(sender:)))
            doneBarButtonItem.isEnabled = viewModel.selectionContainer.isFilled
            navigationItem.rightBarButtonItem = doneBarButtonItem
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
        setupTitleView: do {
            title = viewModel.assetCollection.localizedTitle
        }
        loadPhotos()
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.selectionContainer.selectedCount > 0
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func loadPhotos() {
        viewModel.fetchPhotos { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.restoreSelectionState()
            }
        }
    }
    
    func restoreSelectionState() {
        for selectedIndex in viewModel.selectedIndexs.map({ IndexPath(row: $0, section: 0) }) {
            collectionView.selectItem(at: selectedIndex, animated: false, scrollPosition: .top)
        }
    }
    
    // MARK: User Interaction
    
    @IBAction func didPickAssets(sender: Any) {
        //TODO Display loader
        viewModel.downloadSelectedCells { [weak self] images in
            guard self != nil else { return } //User cancelled the request
            NotificationCenter.default.post(name: PhotoPickerPickImageNotificationName, object: images)
            //TODO Stop loader
        }
    }

    @objc func resetSelection() {
        collectionView.indexPathsForSelectedItems?.forEach { collectionView.deselectItem(at: $0, animated: true) }
        viewModel.reset(withAssetCollection: viewModel.assetCollection)
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = false
    }
}

extension AssetDetailViewController: UICollectionViewDelegate {
    @objc dynamic
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? AssetDetailCellBindable else { return }
        
        cell.cellViewModel?.cancelPreviewImageIfNeeded()
        cell.cellViewModel?.delegate = nil
        cell.cellViewModel = nil
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView.allowsMultipleSelection, self.viewModel.selectionContainer.isFilled {
            return false
        }
        
        return true
    }

    @objc dynamic public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        guard let cellViewModel = (cell as? AssetDetailCellBindable)?.cellViewModel else { return }

        self.viewModel.toggle(item: cellViewModel)
        if case .notSelected = cellViewModel.selectionStatus() {
            collectionView.deselectItem(at: indexPath, animated: true)
        }

        if (collectionView.indexPathsForSelectedItems ?? []).count > 0 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(resetSelection))
        }
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.selectionContainer.selectedCount > 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        guard let cellViewModel = (cell as? AssetDetailCellBindable)?.cellViewModel else { return }
        
        self.viewModel.toggle(item: cellViewModel)
        if (collectionView.indexPathsForSelectedItems ?? []).isEmpty {
            navigationItem.leftBarButtonItem = nil
            navigationItem.hidesBackButton = false
        }
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.selectionContainer.selectedCount > 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cellProtocol = cell as? AssetDetailCellBindable else { return }
        let cellViewModel = viewModel.cellModel(at: indexPath.item)
        cellProtocol.bind(cellViewModel: cellViewModel)
        
        cell.isSelected = cellViewModel.selectionStatus() != .notSelected
        
        if (collectionView.isDragging || collectionView.isDecelerating), !viewModel.configuration.disableOnLibraryScrollAnimation {
            cell.alpha = 0.5
            
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
                cell.alpha = 1
            }, completion: nil)
        }
    }
}

extension AssetDetailViewController: UICollectionViewDataSource {
    @objc dynamic public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.configuration.cellRegistrator.cellIdentifier(forCellType: .asset), for: indexPath)
        if let cell = cell as? AssetDetailCell {
            cell.configuration = viewModel.configuration
        }
        return cell
    }
    
    @objc dynamic public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    @objc dynamic public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.displayItems.count
    }
    
    @objc dynamic public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: AssetDetailHeaderContainerView.self), for: indexPath) as? AssetDetailHeaderContainerView else { return UICollectionReusableView() }
            
            guard let headerView = viewModel.configuration.headerView else { fatalError() }
            view.set(view: headerView)
            
            return view
        } else {
            fatalError()
        }
    }
}

extension AssetDetailViewController: UICollectionViewDelegateFlowLayout {
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
    
    @objc dynamic public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let headerView = viewModel.configuration.headerView else {
            return .zero
        }
        
        if headerSizeCalculator == nil {
            headerSizeCalculator = ViewSizeCalculator(sourceView: headerView, calculateTargetView: { $0 })
        }
        
        return headerSizeCalculator?.calculate(width: collectionView.bounds.width, height: nil, cacheKey: nil, closure: { _ in }) ?? .zero
    }
}


public final class ViewModel {
    
    // MARK: Properties
    
    private let imageManager = PHCachingImageManager()
    private(set) var assetCollection: PHAssetCollection
    private(set) var selectionContainer: SelectionContainer<AssetDetailCellViewModel>
    private(set) var displayItems: PHFetchResult<PHAsset>
    let configuration: AssetPickerConfiguration
    var selectedIndexs: [Int] {
        let selectedAssets = selectionContainer.selectedItems.map { $0.asset }
        return selectedAssets.compactMap { displayItems.contains($0) ? displayItems.index(of: $0) : nil }
    }

    // MARK: Lifecycle
    
    init(assetCollection: PHAssetCollection, selectionContainer: SelectionContainer<AssetDetailCellViewModel>, configuration: AssetPickerConfiguration) {
        self.assetCollection = assetCollection
        self.selectionContainer = selectionContainer
        self.displayItems = PHFetchResult<PHAsset>()
        self.configuration = configuration
    }
    
    func fetchPhotos(onNext: @escaping (() -> ())) {
        DispatchQueue.global(qos: .userInteractive).async {
            
            let fetchOptions = PHFetchOptions()
            
            if !self.configuration.supportOnlyMediaType.isEmpty {
                let predicates = self.configuration.supportOnlyMediaType.map { NSPredicate(format: "mediaType = %d", $0.rawValue) }
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
    
    func cellModel(at index: Int) -> AssetDetailCellViewModel {
        
        let asset = displayItems.object(at: index)
        
        if let cellModel = selectionContainer.item(for: asset.localIdentifier) {
            return cellModel
        }
        
        let cellModel = makeCellModel(from: asset)
        
        return cellModel
    }
    
    private func makeCellModel(from asset: PHAsset) -> AssetDetailCellViewModel {
        
        let cellModel = AssetDetailCellViewModel(
            asset: asset,
            imageManager: imageManager,
            selectionContainer: selectionContainer
        )
        
        return cellModel
    }
    
    func toggle(item: AssetDetailCellViewModel) {
        if case .notSelected = item.selectionStatus() {
            select(item: item)
        } else {
            unselect(item: item)
        }
    }
    
    private func select(item: AssetDetailCellViewModel) {
        selectionContainer.append(item: item, removeFirstIfAlreadyFilled: selectionContainer.size == 1)
    }
    
    private func unselect(item: AssetDetailCellViewModel) {
        selectionContainer.remove(item: item)
    }
}


