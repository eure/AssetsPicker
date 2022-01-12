//
//  PhotosPickerAssetsCollectionViewController.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/16.
//  Copyright © 2018 eureka, Inc. All rights reserved.
//

#if os(iOS)
import Photos
import UIKit

final class AssetsCollectionViewController: UIViewController {
    // MARK: Properties

    private let viewModel: AssetCollectionViewModel
    private var selectionContainer: SelectionContainer<AssetDetailCellViewModel>!
    let configuration: MosaiqueAssetPickerConfiguration

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = configuration.cellSpacing
        layout.minimumInteritemSpacing = configuration.cellSpacing

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = UIColor.systemBackground
        } else {
            collectionView.backgroundColor = .white
        }
        collectionView.delegate = self
        collectionView.dataSource = self

        if let nib = configuration.cellRegistrator.customAssetItemNibs[.assetCollection]?.0 {
            collectionView.register(nib, forCellWithReuseIdentifier: configuration.cellRegistrator.cellIdentifier(forCellType: .assetCollection))
        } else {
            collectionView.register(
                configuration.cellRegistrator.cellType(forCellType: .assetCollection),
                forCellWithReuseIdentifier: configuration.cellRegistrator.cellIdentifier(forCellType: .assetCollection)
            )
        }

        collectionView.alwaysBounceVertical = false

        return collectionView
    }()

    init(configuration: MosaiqueAssetPickerConfiguration) {
        self.configuration = configuration
        viewModel = AssetCollectionViewModel(configuration: configuration)
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupConfiguration: do {
            switch configuration.selectionMode {
            case .single:
                selectionContainer = SelectionContainer<AssetDetailCellViewModel>(withSize: 1)
            case let .multiple(limit):
                selectionContainer = SelectionContainer<AssetDetailCellViewModel>(withSize: limit)
            }
        }
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
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        }

        if PHPhotoLibrary.authorizationStatus() == .denied {
            fatalError("Permission denied for accessing to photos.")
        }
    }
}

extension AssetsCollectionViewController: UICollectionViewDataSource {
    @objc public dynamic func numberOfSections(in _: UICollectionView) -> Int {
        viewModel.displayItems.isEmpty ? 0 : 1
    }

    @objc public dynamic func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        viewModel.displayItems.count
    }

    @objc public dynamic func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: configuration.cellRegistrator.cellIdentifier(forCellType: .assetCollection), for: indexPath)

        return cell
    }
}

extension AssetsCollectionViewController: UICollectionViewDelegate {
    @objc public dynamic func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let assetCollection = viewModel.displayItems[indexPath.item].assetCollection
        let assetDetailController = AssetDetailViewController(withAssetCollection: assetCollection, andSelectionContainer: selectionContainer, configuration: configuration)
        navigationController?.pushViewController(assetDetailController, animated: true)
    }

    public func collectionView(_: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? AssetCollectionCellBindable else { return }

        let cellViewModel = viewModel.displayItems[indexPath.item]
        cell.bind(cellViewModel: cellViewModel)
    }

    @objc public dynamic
    func collectionView(_: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt _: IndexPath) {
        guard let cell = cell as? AssetCollectionCellBindable else { return }

        cell.cellViewModel?.cancelLatestImageIfNeeded()
        cell.cellViewModel?.delegate = nil
        cell.cellViewModel = nil
    }
}

extension AssetsCollectionViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 80)
    }

    @objc public dynamic func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        0
    }

    @objc public dynamic func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        5
    }
}

extension AssetsCollectionViewController: AssetCollectionViewModelDelegate {
    func updatedCollections() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
}
#endif
