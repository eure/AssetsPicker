//
//  PhotoPicker.AssetDetailViewController.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/18.
//  Copyright © 2018 eureka, Inc. All rights reserved.
//

#if os(iOS)
import Photos
import UIKit

public final class AssetDetailViewController: UIViewController {
    // MARK: Properties

    let viewModel: AssetDetailViewModel
    var headerSizeCalculator: ViewSizeCalculator<UIView>?
    private var collectionView: UICollectionView!
    let configuration: MosaiqueAssetPickerConfiguration

    private var gridCount: Int {
        viewModel.configuration.numberOfItemsPerRow
    }

    // MARK: Lifecycle

    init(withAssetCollection assetCollection: PHAssetCollection, andSelectionContainer selectionContainer: SelectionContainer<AssetDetailCellViewModel>, configuration: MosaiqueAssetPickerConfiguration) {
        viewModel = AssetDetailViewModel(
            assetCollection: assetCollection,
            selectionContainer: selectionContainer,
            configuration: configuration
        )
        self.configuration = configuration

        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemBackground
        } else {
            view.backgroundColor = .white
        }

        setupView: do {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = configuration.cellSpacing
            layout.minimumInteritemSpacing = configuration.cellSpacing
            layout.sectionHeadersPinToVisibleBounds = viewModel.configuration.isHeaderFloating

            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

            collectionView.allowsSelection = true

            if #available(iOS 13.0, *) {
                collectionView.backgroundColor = UIColor.systemBackground
            } else {
                collectionView.backgroundColor = .white
            }

            switch viewModel.configuration.selectionMode {
            case .single:
                collectionView.allowsMultipleSelection = false
            case let .multiple(size):
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
            let doneBarButtonItem = UIBarButtonItem(title: viewModel.configuration.localize.done, style: .done, target: self, action: #selector(didPickAssets))
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
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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

    override public func viewWillAppear(_ animated: Bool) {
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

    @IBAction func didPickAssets() {
        let downloads = viewModel.downloadSelectedCells { [weak self] images in
            guard self != nil else { return } // User cancelled the request
            NotificationCenter.assetPicker.post(name: PhotoPickerPickImagesNotificationName, object: images)
        }
        NotificationCenter.assetPicker.post(name: PhotoPickerPickAssetsNotificationName, object: downloads)
    }

    func updateNavigationItems() {
        guard let doneButton = navigationItem.rightBarButtonItem else { return }

        let selectedCount = (collectionView.indexPathsForSelectedItems ?? []).count
        doneButton.isEnabled = selectedCount > 0
        let suffix = (doneButton.isEnabled && configuration.selectionMode.case != .single) ? " (\(selectedCount))" : ""
        doneButton.title = configuration.localize.done + suffix
    }
}

extension AssetDetailViewController: UICollectionViewDelegate {
    @objc public dynamic
    func collectionView(_: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt _: IndexPath) {
        guard let cell = cell as? AssetDetailCellBindable else { return }

        cell.cellViewModel?.cancelPreviewImageIfNeeded()
        cell.cellViewModel?.delegate = nil
        cell.cellViewModel = nil
    }

    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt _: IndexPath) -> Bool {
        if collectionView.allowsMultipleSelection, viewModel.selectionContainer.isFilled {
            return false
        }
        return true
    }

    @objc public dynamic func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        guard let cellViewModel = (cell as? AssetDetailCellBindable)?.cellViewModel else { return }

        viewModel.toggle(item: cellViewModel)
        if case .notSelected = cellViewModel.selectionStatus() {
            collectionView.deselectItem(at: indexPath, animated: true)
        }

        if configuration.selectionMode.case == .single, configuration.singleSelectionNeedsConfirmation == false {
            didPickAssets()
        } else {
            updateNavigationItems()
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        guard let cellViewModel = (cell as? AssetDetailCellBindable)?.cellViewModel else { return }

        viewModel.toggle(item: cellViewModel)
        updateNavigationItems()
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cellProtocol = cell as? AssetDetailCellBindable else { return }
        let cellViewModel = viewModel.cellModel(at: indexPath.item)
        cellProtocol.bind(cellViewModel: cellViewModel)

        cell.isSelected = cellViewModel.selectionStatus() != .notSelected

        if collectionView.isDragging || collectionView.isDecelerating, !viewModel.configuration.disableOnLibraryScrollAnimation {
            cell.alpha = 0.5

            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
                cell.alpha = 1
            }, completion: nil)
        }
    }
}

extension AssetDetailViewController: UICollectionViewDataSource {
    @objc public dynamic func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.configuration.cellRegistrator.cellIdentifier(forCellType: .asset), for: indexPath)
        if let cell = cell as? AssetDetailCell {
            cell.selectionColor = viewModel.configuration.selectionColor
        } else {
            assertionFailure("Mismatched type of cell")
        }
        return cell
    }

    @objc public dynamic func numberOfSections(in _: UICollectionView) -> Int {
        1
    }

    @objc public dynamic func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        viewModel.displayItems.count
    }

    @objc public dynamic func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
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
    @objc public dynamic func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        HorizontalStackItemSizeCalculator.square(
            width: collectionView.bounds.width,
            spacing: configuration.cellSpacing,
            itemCount: gridCount,
            itemIndex: indexPath.item
        )
    }

    @objc public dynamic func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection _: Int) -> CGSize {
        guard let headerView = viewModel.configuration.headerView else {
            return .zero
        }

        if headerSizeCalculator == nil {
            headerSizeCalculator = ViewSizeCalculator(sourceView: headerView, calculateTargetView: { $0 })
        }

        return headerSizeCalculator?.calculate(width: collectionView.bounds.width, height: nil, cacheKey: nil, closure: { _ in }) ?? .zero
    }
}

extension AssetDetailViewController: AssetDetailViewModelDelegate {
    public func displayItemsChange(_: PHFetchResultChangeDetails<PHAsset>) {
        restoreSelectionState()
        collectionView.reloadData()
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.selectionContainer.selectedCount > 0
    }
}

private enum HorizontalStackItemSizeCalculator {
    static func square(width: CGFloat, spacing: CGFloat, itemCount: Int, itemIndex: Int) -> CGSize {
        let (height, _) = components(width: width, spacing: spacing, itemCount: itemCount)
        let width = cal(width: width, spacing: spacing, itemCount: itemCount, indexInRow: itemIndex % itemCount)
        return CGSize(width: width, height: height)
    }

    static func cal(width: CGFloat, spacing: CGFloat, itemCount: Int, itemIndex: Int) -> CGFloat {
        cal(width: width, spacing: spacing, itemCount: itemCount, indexInRow: itemIndex % itemCount)
    }

    static func components(width: CGFloat, spacing: CGFloat, itemCount: Int) -> (unit: CGFloat, extra: CGFloat) {
        let itemCount_f = CGFloat(itemCount)
        let targetWidth = width - (spacing * (itemCount_f - 1))
        let extra = targetWidth.truncatingRemainder(dividingBy: itemCount_f)
        let unit = (targetWidth - extra) / itemCount_f

        return (unit: unit, extra: extra)
    }

    static func cal(width: CGFloat, spacing: CGFloat, itemCount: Int, indexInRow: Int) -> CGFloat {
        assert(indexInRow < itemCount)

        let (unit, extra) = components(width: width, spacing: spacing, itemCount: itemCount)

        if indexInRow == 1 {
            return unit + extra
        } else {
            return unit
        }
    }
}
#endif
