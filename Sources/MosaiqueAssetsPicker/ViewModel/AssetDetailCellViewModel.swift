//
//  PhotosPicker.AssetDetailViewController.CellViewModel.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/19.
//  Copyright © 2018 eureka, Inc. All rights reserved.
//
#if os(iOS)
import Foundation
import Photos
import UIKit.UIImage

public protocol AssetDetailCellViewModelDelegate: AnyObject {
    func cellViewModel(_ cellViewModel: AssetDetailCellViewModel, didFetchImage image: UIImage)
    func cellViewModel(_ cellViewModel: AssetDetailCellViewModel, isDownloading: Bool)
}

public extension AssetDetailCellViewModelDelegate {
    func cellViewModel(_: AssetDetailCellViewModel, isDownloading _: Bool) {}
}

public final class AssetDetailCellViewModel: ItemIdentifier {
    // MARK: Inner

    enum Selection: Equatable {
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
    private var assetFuture: AssetFuture?
    private weak var weakThumbnail: UIImage?
    private var thumbnail: UIImage?

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

        if let index = selectionContainer.selectedItems.firstIndex(where: { $0.identifier == asset.localIdentifier }) {
            selectionState = Selection.selected(number: index + 1)
        }

        return selectionState
    }

    // MARK: Network

    public func fetchPreviewImage() {
        imagePreviewId = _fetchPreviewImage(onNext: { [weak self] image, _ in
            if let image = image {
                guard let self = self else { return }
                self.delegate?.cellViewModel(self, didFetchImage: image)
            } else {
                print("cannot download image for id = \(String(describing: self?.asset.localIdentifier))")
            }
        })
    }

    private func _fetchPreviewImage(
        onNext: @escaping (UIImage?, [AnyHashable: Any]?) -> Void,
        size: CGSize = CGSize(width: 360, height: 360)
    ) -> PHImageRequestID {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        options.version = .current
        options.resizeMode = .fast
        return imageManager.requestImage(for: asset,
                                         targetSize: size,
                                         contentMode: .aspectFill,
                                         options: options,
                                         resultHandler: onNext)
    }

    func download(onNext: @escaping ((UIImage?) -> Void)) -> AssetFuture {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.version = .current
        options.resizeMode = .exact
        isDownloading = true
        let assetFuture = AssetFuture(asset: asset) {
            switch $0 {
            case let .success(image):
                onNext(image)
            case .failure:
                onNext(nil)
            }
        }
        let imageRequestID = imageManager.requestImage(
            for: asset,
            targetSize: CGSize(width: 1920, height: 1920),
            contentMode: .default,
            options: options
        ) { [weak self, weak assetFuture] image, userInfo in
            self?.isDownloading = false
            if let image = image {
                assetFuture?.finalImageResult = .success(image)
            } else {
                let error = userInfo?["PHImageErrorKey"] as? NSError
                assetFuture?.finalImageResult = .failure(error ?? AssetFuture.Error.unknownError)
            }
        }
        assetFuture.thumbnailRequestID = _fetchPreviewImage(onNext: { [weak assetFuture] image, userInfo in
            if let image = image {
                assetFuture?.thumbnailResult = .success(image)
            } else {
                let error = userInfo?["PHImageErrorKey"] as? NSError
                assetFuture?.thumbnailResult = .failure(error ?? AssetFuture.Error.unknownError)
            }
        }, size: .init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
        assetFuture.imageRequestID = imageRequestID
        return assetFuture
    }

    public func cancelPreviewImageIfNeeded() {
        guard let imageRequestId = imagePreviewId else { return }
        PHCachingImageManager.default().cancelImageRequest(imageRequestId)
        imagePreviewId = nil
    }

    // MARK: ItemIdentifier

    public var identifier: String {
        asset.localIdentifier
    }
}
#endif
