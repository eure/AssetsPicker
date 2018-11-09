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

extension PhotosPicker {
    
    public class SelectAssetCollectionContainerViewController: UIViewController {
        
        // MARK: Properties
        
        private lazy var changePermissionsButton: UIButton = {
          let button = UIButton(type: UIButton.ButtonType.custom)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            button.setTitleColor(Configuration.shared.tintColor, for: .normal)

            return button
        }()
        private let viewModel = AssetCollectionViewModel()
        private lazy var assetsCollectionsViewController = PhotosPicker.AssetsCollectionViewController()
        private var currentAnimator: UIViewPropertyAnimator?
        private var isShowingCollection: Bool = false
        private var currentAssetDetailViewController: PhotosPicker.AssetDetailViewController?
        private let selectionContainer: SelectionContainer<PhotosPicker.AssetDetailViewController.CellViewModel>
        private let titleButton = PhotosPicker.TitleView()

        // MARK: Lifecycle
        
        init() {
        
            setupConfiguration: do {
                
                switch PhotosPicker.Configuration.shared.selectionMode {
                case .single:
                    self.selectionContainer = SelectionContainer<PhotosPicker.AssetDetailViewController.CellViewModel>(withSize: 1)
                case .multiple(let limit):
                    self.selectionContainer = SelectionContainer<PhotosPicker.AssetDetailViewController.CellViewModel>(withSize: limit)
                }
                
                super.init(nibName: nil, bundle: nil)
            }
            
            setupDismissButton: do {
                let dismissBarButtonItem = UIBarButtonItem(title: PhotosPicker.Configuration.shared.localize.dismiss, style: .done, target: self, action: #selector(dismissPicker(sender:)))
                dismissBarButtonItem.tintColor = PhotosPicker.Configuration.shared.tintColor
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
            
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                setupController()
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    if newStatus == .authorized {
                        DispatchQueue.main.async {
                            self.setupController()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.showPermissionsLabel()
                        }
                    }
                })
            case .denied, .restricted:
                showPermissionsLabel()
            }
        }
        
        func showPermissionsLabel() {
            titleButton.isHidden = true
            view.addSubview(changePermissionsButton)
            changePermissionsButton.translatesAutoresizingMaskIntoConstraints = false
            changePermissionsButton.setTitle(Configuration.shared.localize.changePermissions, for: .normal)
            changePermissionsButton.addTarget(self, action: #selector(openSettings(sender:)), for: .touchUpInside)
            NSLayoutConstraint.activate([
                changePermissionsButton.topAnchor.constraint(equalTo: view.topAnchor),
                changePermissionsButton.leftAnchor.constraint(equalTo: view.leftAnchor),
                changePermissionsButton.rightAnchor.constraint(equalTo: view.rightAnchor),
                changePermissionsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                ]
            )
        }
        
        @objc func openSettings(sender: UIButton) {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        
        func setupController() {
            setupAssetsCollection: do {
                addChild(assetsCollectionsViewController)
                assetsCollectionsViewController.didMove(toParent: self)
                assetsCollectionsViewController.delegate = self
            }
            setupInitialState: do {
                viewModel.loadAssets()
                if let assetCollection = viewModel.cameraRollAssetCollection {
                    setup(toAssetCollection: assetCollection)
                } else {
                    fatalError("no cameral roll!!!!")
                }
            }
        }
        
        // MARK: User Interaction
        
        @objc func dismissPicker(sender: Any) {
            self.dismiss(animated: true, completion: nil)
        }
        
        @objc func showCollections(sender: Any) {
            if self.isShowingCollection {
                self.hideCollections()
            } else {
                self.showCollections()
            }
        }
        
        // MARK: Core
        
        private func setup(toAssetCollection assetCollection: PHAssetCollection) {
            let controller = PhotosPicker.AssetDetailViewController(withAssetCollection: assetCollection, andSelectionContainer: selectionContainer)
            
            controller.delegate = self
            
            addChild(controller)
            currentAssetDetailViewController = controller
            
            view.insertSubview(controller.view, at: 0)
            
            guard let view = view else { return }
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                controller.view.topAnchor.constraint(equalTo: view.topAnchor),
                controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        private func switchTo(assetCollection: PHAssetCollection) {
            guard currentAssetDetailViewController?.viewModel.assetCollection != assetCollection else {
                // It's currently displayed
                return
            }
            
            titleButton.setTitle(assetCollection.localizedTitle ?? PhotosPicker.Configuration.shared.localize.collections, for: .normal)
            titleButton.sizeToFit()
            currentAssetDetailViewController?.viewModel.reset(withAssetCollection: assetCollection)
            currentAssetDetailViewController?.loadPhotos()
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
}

// MARK: PhotosPickerAssetsCollectionDelegate

extension PhotosPicker.SelectAssetCollectionContainerViewController: PhotosPickerAssetsCollectionDelegate {
    func photoPicker(_ selectAssetController: PhotosPicker.AssetsCollectionViewController, didSelectAsset asset: PHAssetCollection) {
        hideCollections()
        switchTo(assetCollection: asset)
    }
}

// MARK: PhotosPickerAssetDetailDelegate

extension PhotosPicker.SelectAssetCollectionContainerViewController: PhotosPickerAssetDetailDelegate {
    func photoPicker(_ pickerController: PhotosPicker.AssetDetailViewController, didPickImages images: [UIImage]) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PhotoPickerPickImageNotification), object: images)
    }
}
