//
//  PhotosPickerSelectAssetsViewController.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/16.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import UIKit
import Photos

final class SelectAssetCollectionContainerViewController: UIViewController {
    
    // MARK: Properties
    
    private var currentAnimator: UIViewPropertyAnimator?
    private var isShowingCollection: Bool = false
    private var currentAssetDetailViewController: AssetDetailViewController?
    
    private let selectionContainer: SelectionContainer<AssetDetailCellViewModel>
    private let titleButton = AssetPickerTitleView()
    private let viewModel = AssetCollectionViewModel()
    
    private lazy var assetsCollectionsViewController = AssetsCollectionViewController()
    private lazy var changePermissionsButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.setTitleColor(AssetPickerConfiguration.shared.tintColor, for: .normal)
        
        return button
    }()
    
    // MARK: Lifecycle
    
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
        
        setupDismissButton: do {
            let dismissBarButtonItem = UIBarButtonItem(title: AssetPickerConfiguration.shared.localize.dismiss, style: .done, target: self, action: #selector(dismissPicker(sender:)))
            dismissBarButtonItem.tintColor = AssetPickerConfiguration.shared.tintColor
            navigationItem.leftBarButtonItem = dismissBarButtonItem
        }
        setupTitleView: do {
            self.navigationItem.titleView = titleButton
            titleButton.addTarget(self, action: #selector(showCollections(sender:)), for: .touchUpInside)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        handleAuthorizations()
    }
    
    // MARK: User Interaction
    
    @objc func openSettings(sender: UIButton) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    
    private func handleAuthorizations() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            setup()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized {
                    self.setup()
                } else {
                    self.showPermissionsLabel()
                }
            }
        case .denied, .restricted:
            showPermissionsLabel()
        @unknown default:
            break
        }
    }
    
    @objc func dismissPicker(sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PhotoPickerCancelNotification), object: nil)
    }
    
    @objc func showCollections(sender: Any) {
        if self.isShowingCollection {
            self.hideCollections()
        } else {
            self.showCollections()
        }
    }
    
    private func showPermissionsLabel() {
        titleButton.isHidden = true
        
        view.addSubview(changePermissionsButton)
        
        changePermissionsButton.translatesAutoresizingMaskIntoConstraints = false
        changePermissionsButton.setTitle(AssetPickerConfiguration.shared.localize.changePermissions, for: .normal)
        changePermissionsButton.addTarget(self, action: #selector(openSettings(sender:)), for: .touchUpInside)
       
        NSLayoutConstraint.activate([
            changePermissionsButton.topAnchor.constraint(equalTo: view.topAnchor),
            changePermissionsButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            changePermissionsButton.rightAnchor.constraint(equalTo: view.rightAnchor),
            changePermissionsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ]
        )
    }
    
    private func switchTo(assetCollection: PHAssetCollection) {
        // We do nothing if the user selected the same asset
        guard currentAssetDetailViewController?.viewModel.assetCollection != assetCollection else { return }
        
        titleButton.setTitle(assetCollection.localizedTitle ?? AssetPickerConfiguration.shared.localize.collections, for: .normal)
        titleButton.sizeToFit()
        
        currentAssetDetailViewController?.viewModel.reset(withAssetCollection: assetCollection)
        currentAssetDetailViewController?.loadPhotos()
    }
    
    // MARK: Setup
    
    func setup() {
        addChild(assetsCollectionsViewController)
        assetsCollectionsViewController.didMove(toParent: self)
        assetsCollectionsViewController.delegate = self

        viewModel.loadCameraRollAsset() { [weak self] in
            
            guard let `self` = self else { return }
        
            DispatchQueue.main.async {
                if let assetCollection = self.viewModel.cameraRollAssetCollection {
                    let assetDetailController = AssetDetailViewController(withAssetCollection: assetCollection, andSelectionContainer: self.selectionContainer)
                    assetDetailController.delegate = self
                    
                    self.addChild(assetDetailController)
                    self.currentAssetDetailViewController = assetDetailController
                    
                    self.view.addSubview(assetDetailController.view)
                    
                    assetDetailController.view.translatesAutoresizingMaskIntoConstraints = false
                    
                    NSLayoutConstraint.activate([
                        assetDetailController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
                        assetDetailController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                        assetDetailController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                        assetDetailController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                        ])
                } else {
                    fatalError("no cameral roll!!!!")
                }
            }
        }
    }

    // Assets Collection
    
    private func showCollections() {
        titleButton.setOpened()
        currentAnimator?.stopAnimation(true)
        
        isShowingCollection = true
        
        view.addSubview(assetsCollectionsViewController.view)
        assetsCollectionsViewController.view.transform = .identity
        
        assetsCollectionsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            assetsCollectionsViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            assetsCollectionsViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            assetsCollectionsViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            assetsCollectionsViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        assetsCollectionsViewController.view.transform = .init(translationX: 0, y: -assetsCollectionsViewController.view.bounds.height)
        
        let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1) {
            self.assetsCollectionsViewController.view.transform = .identity
        }
        
        animator.startAnimation()
        
        currentAnimator = animator
    }
    
    private func hideCollections() {
        titleButton.setClosed()
        currentAnimator?.stopAnimation(true)
        
        isShowingCollection = false
        
        assetsCollectionsViewController.view.transform = .identity
        
        let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1) {
            self.assetsCollectionsViewController.view.transform = .init(translationX: 0, y: -self.assetsCollectionsViewController.view.bounds.height)
        }
        
        animator.addCompletion { (_) in
            self.assetsCollectionsViewController.view.removeFromSuperview()
        }
        
        animator.startAnimation()
        
        currentAnimator = animator
    }
}


// MARK: PhotosPickerAssetsCollectionDelegate

extension SelectAssetCollectionContainerViewController: PhotosPickerAssetsCollectionDelegate {
    func photoPicker(_ selectAssetController: AssetsCollectionViewController, didSelectAsset asset: PHAssetCollection) {
        hideCollections()
        switchTo(assetCollection: asset)
    }
}

// MARK: PhotosPickerAssetDetailDelegate

extension SelectAssetCollectionContainerViewController: PhotosPickerAssetDetailDelegate {
    func photoPicker(_ pickerController: AssetDetailViewController, didPickImages images: [UIImage]) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PhotoPickerPickImageNotification), object: images)
    }
}
