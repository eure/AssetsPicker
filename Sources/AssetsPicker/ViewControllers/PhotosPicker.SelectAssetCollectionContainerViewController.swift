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
    
    public class SelectAssetCollectionContainerViewController: BaseViewController<AssetCollectionViewModel> {
        
        // MARK: Properties
        
        private lazy var assetsCollectionsViewController = PhotosPicker.AssetsCollectionViewController(viewModel: .init())
        private var currentAnimator: UIViewPropertyAnimator?
        private var isShowingCollection: Bool = false
        private let configuration: PhotosPicker.Configuration
        private var currentAssetDetailViewController: PhotosPicker.AssetDetailViewController?
        private let selectionContainer: SelectionContainer<PhotosPicker.AssetDetailViewController.CellViewModel>
        private let titleButton = UIButton()

        // MARK: Lifecycle
        
        init(withViewModel viewModel: AssetCollectionViewModel, configuration: PhotosPicker.Configuration) {
            
            setupConfiguration: do {
                self.configuration = configuration
                
                switch configuration.selectionMode {
                case .single:
                    self.selectionContainer = SelectionContainer<PhotosPicker.AssetDetailViewController.CellViewModel>(withSize: 1)
                case .multiple(let limit):
                    self.selectionContainer = SelectionContainer<PhotosPicker.AssetDetailViewController.CellViewModel>(withSize: limit)
                }
            }
            
            super.init(viewModel: viewModel)
            
            setupDismissButton: do {
                let dismissBarButtonItem = UIBarButtonItem(title: configuration.localize.dismiss, style: .done, target: self, action: #selector(dismissPicker(sender:)))
                dismissBarButtonItem.tintColor = configuration.tintColor
                navigationItem.leftBarButtonItem = dismissBarButtonItem
            }
            setupTitleView: do {
                titleButton.setTitleColor(PhotosPicker.Configuration.shared.tintColor, for: .normal)
                titleButton.setTitle(PhotosPicker.Configuration.shared.localize.collections, for: .normal)
                self.navigationItem.titleView = titleButton
                titleButton.addTarget(self, action: #selector(showCollections(sender:)), for: .touchUpInside)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func viewDidLoad() {
            super.viewDidLoad()
            
            setupAssetsCollection: do {
                addChild(assetsCollectionsViewController)
                assetsCollectionsViewController.didMove(toParent: self)
                assetsCollectionsViewController.delegate = self
            }
            setupInitialState: do {
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
            let controller = PhotosPicker.AssetDetailViewController(
                viewModel: PhotosPicker.ViewModel(
                    assetCollection: assetCollection,
                    selectionContainer: selectionContainer
                )
            )
            
            controller.delegate = self
            
            addChild(controller)
            currentAssetDetailViewController = controller
            
            view.insertSubview(controller.view, at: 0)
            
            guard let view = view else { return }
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        
        private func switchTo(assetCollection: PHAssetCollection) {
            guard currentAssetDetailViewController?.viewModel.assetCollection != assetCollection else {
                // It's currently displayed
                return
            }
            
            titleButton.setTitle(assetCollection.localizedTitle ?? PhotosPicker.Configuration.shared.localize.collections, for: .normal)
            currentAssetDetailViewController?.viewModel.reset(withAssetCollection: assetCollection)
            currentAssetDetailViewController?.loadPhotos()
        }
        
        // Assets Collection
        
        private func showCollections() {
            currentAnimator?.stopAnimation(true)
            
            isShowingCollection = true
            
            view.addSubview(assetsCollectionsViewController.view)
            assetsCollectionsViewController.view.transform = .identity
            
            assetsCollectionsViewController.view.translatesAutoresizingMaskIntoConstraints = false
            assetsCollectionsViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            assetsCollectionsViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            assetsCollectionsViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            assetsCollectionsViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            assetsCollectionsViewController.view.transform = .init(translationX: 0, y: -assetsCollectionsViewController.view.bounds.height)
            
            let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1) {
                self.assetsCollectionsViewController.view.transform = .identity
            }

            animator.startAnimation()
            
            currentAnimator = animator
        }
        
        private func hideCollections() {
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
