//
//  PhotosPicker.AssetDetailViewController.CellViewModel.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/19.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import Photos

public protocol AssetDetailCellViewModelDelegate: class {
    func cellViewModel(_ cellViewModel: AssetDetailCellViewModel, didFetchImage image: UIImage)
    func cellViewModel(_ cellViewModel: AssetDetailCellViewModel, isDownloading: Bool)
}

public extension AssetDetailCellViewModelDelegate {
    func cellViewModel(_ cellViewModel: AssetDetailCellViewModel, isDownloading: Bool) {}
}

public final class AssetDetailCellViewModel: ItemIdentifier {
    // MARK: Inner
    
    enum Selection : Equatable {
        
        case notSelected
        case selected(number: Int)
    }
    
    // MARK: Properties
    
    public weak var delegate: AssetDetailCellViewModelDelegate?
    public var isDownloading = false {
        didSet {
            delegate?.cellViewModel(self, isDownloading: isDownloading)
        }
    }
    public let asset: PHAsset
    private let imageManager: PHCachingImageManager
    private let selectionContainer: SelectionContainer<AssetDetailCellViewModel>
    private var imagePreviewId: PHImageRequestID?
    private var imageDownloadId: PHImageRequestID?
    private var taskID = UIBackgroundTaskIdentifier.invalid

    // MARK: Lifecycle
    
    init(
        asset: PHAsset,
        imageManager: PHCachingImageManager,
        selectionContainer: SelectionContainer<AssetDetailCellViewModel>
        ) {
        
        self.asset = asset
        self.imageManager = imageManager
        self.selectionContainer = selectionContainer
    }
    
    func selectionStatus() -> Selection {
        var selectionState = Selection.notSelected
        
        if let index = self.selectionContainer.selectedItems.firstIndex(where: { $0.identifier == asset.localIdentifier }) {
            selectionState = Selection.selected(number: index + 1)
        }
        
        return selectionState
    }
    
    // MARK: Network
    
    public func fetchPreviewImage() {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        options.version = .current
        options.resizeMode = .fast
        self.imagePreviewId = imageManager.requestImage(
            for: asset,
            targetSize: CGSize(width: 360, height: 360),
            contentMode: .aspectFill,
            options: options) { [weak self] image, _ in
                if let image = image {
                    guard let self = self else { return }
                    self.delegate?.cellViewModel(self, didFetchImage: image)
                } else {
                    print("cannot download image for id = \(String(describing: self?.asset.localIdentifier))")
                }
        }
    }

    private func cancelBackgroundTaskIfNeed() {
        guard self.taskID != .invalid else { return }
        objc_sync_enter(self)
        guard self.taskID != .invalid else { return }
        UIApplication.shared.endBackgroundTask(self.taskID)
        self.taskID = .invalid
        objc_sync_exit(self)
    }

    func download(onNext: @escaping ((UIImage?) -> ())) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.version = .current
        options.resizeMode = .exact
        isDownloading = true
        self.taskID = UIApplication.shared.beginBackgroundTask(expirationHandler: { [weak self] in
            self?.cancelBackgroundTaskIfNeed()
        })
        self.imageDownloadId = imageManager.requestImage(
            for: asset,
            targetSize: CGSize(width: 1920, height: 1920),
            contentMode: .default,
            options: options) { [weak self] (image, userInfo) in
                onNext(image)
                self?.isDownloading = false
                self?.cancelBackgroundTaskIfNeed()
        }
    }

    public func cancelDownloadImageIfNeeded() {
        guard let imageRequestId = imageDownloadId else { return }
        PHCachingImageManager.default().cancelImageRequest(imageRequestId)
        cancelBackgroundTaskIfNeed()
        self.imagePreviewId = nil
    }
    
    public func cancelPreviewImageIfNeeded() {
        guard let imageRequestId = imagePreviewId else { return }
        PHCachingImageManager.default().cancelImageRequest(imageRequestId)
        self.imagePreviewId = nil
    }
    
    // MARK: ItemIdentifier
    
    public var identifier: String {
        return asset.localIdentifier
    }

    deinit {
        cancelBackgroundTaskIfNeed()
    }
}
