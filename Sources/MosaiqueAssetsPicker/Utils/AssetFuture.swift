//
//  AssetFuture.swift
//  AssetsPicker
//
//  Created by Antoine Marandon on 09/12/2019.
//  Copyright © 2019 eureka, Inc. All rights reserved.
//

import Foundation
import Photos
import PhotosUI
import UIKit

/// Represent a picked asset
/// The relevant images might not be available (ie: downloading, resizing) yet.
public class AssetFuture {
    public enum AssetRepresentation {
        public struct PHPickerResultWrapper {
            private let result: Any
            @available(iOS 14, *)
            public var value: PHPickerResult {
                result as! PHPickerResult
            }

            @available(iOS 14, *)
            fileprivate init(_ result: PHPickerResult) {
                self.result = result
            }
        }

        case asset(asset: PHAsset)
        @available(iOS 14, *)
        case result(object: PHPickerResultWrapper)
    }

    @available(*, deprecated, message: "Use assetRepresentation instead")
    public var asset: PHAsset! {
        switch assetRepresentation {
        case let .asset(asset: asset):
            return asset
        default:
            return nil
        }
    }

    public let assetRepresentation: AssetRepresentation
    /// Set this callback to get the final UIImage.
    /// Might be called from a background thread
    /// Might be called immediately if the image is already available.
    public var onComplete: ((Result<UIImage, NSError>) -> Void)? {
        didSet {
            guard onComplete != nil else { return }
            lock.exec {
                if let finalImageResult = self.finalImageResult {
                    onComplete?(finalImageResult)
                    onComplete = nil
                }
            }
            cancelBackgroundTaskIfNeed()
        }
    }

    /// Set this callback to get the thumbnail UIImage.
    /// Might be called from a background thread
    /// Might be called immediately if the image is already available.
    public var onThumbnailCompletion: ((Result<UIImage, NSError>) -> Void)? {
        didSet {
            guard onThumbnailCompletion != nil else { return }
            lock.exec {
                if let thumbnailResult = self.thumbnailResult {
                    onThumbnailCompletion?(thumbnailResult)
                    onThumbnailCompletion = nil
                }
            }
        }
    }

    public internal(set) var thumbnailResult: Result<UIImage, NSError>? {
        didSet {
            guard let thumbnailResult = thumbnailResult else { preconditionFailure("thumbnailResult must not be set to nil") }
            lock.exec {
                onThumbnailCompletion?(thumbnailResult)
                thumbnailRequestID = nil
            }
        }
    }

    public internal(set) var finalImageResult: Result<UIImage, NSError>? {
        didSet {
            lock.exec {
                guard let finalImageResult = finalImageResult else { preconditionFailure("finalImageResult must not be set to nil") }
                onComplete?(finalImageResult)
                imageRequestID = nil
            }
            cancelBackgroundTaskIfNeed()
        }
    }

    private let lock = NSLock()
    private var taskID = UIBackgroundTaskIdentifier.invalid
    internal var thumbnailRequestID: PHImageRequestID?
    internal var imageRequestID: PHImageRequestID?

    init(asset: PHAsset) {
        assetRepresentation = .asset(asset: asset)
        taskID = UIApplication.shared.beginBackgroundTask(withName: "AssetPicker.download", expirationHandler: { [weak self] in
            self?.cancelBackgroundTaskIfNeed()
        })
    }

    @available(iOS 14, *)
    init(pickerResult: PHPickerResult) {
        assetRepresentation = .result(object: .init(pickerResult))
        taskID = UIApplication.shared.beginBackgroundTask(withName: "AssetPicker.download", expirationHandler: { [weak self] in
            self?.cancelBackgroundTaskIfNeed()
        })
        if pickerResult.itemProvider.canLoadObject(ofClass: UIImage.self) {
            pickerResult.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] in
                guard let self = self else { return }
                if let result = $0 as? UIImage {
                    self.finalImageResult = .success(result)
                } else {
                    self.finalImageResult = .failure($1 as NSError? ?? .init())
                }
            }
            pickerResult.itemProvider.loadPreviewImage(options: [:]) { [weak self] in
                guard let self = self else { return }
                if let result = $0 as? UIImage {
                    self.thumbnailResult = .success(result)
                } else if let error = $1 { // If the full size image is readily available, this will fail without error.
                    self.thumbnailResult = .failure(error as NSError)
                }
            }
        } else {
            finalImageResult = .failure(.init())
        }
    }

    deinit {
        if let imageRequestID = self.imageRequestID {
            PHCachingImageManager.default().cancelImageRequest(imageRequestID)
        }
        if let thumbnailRequestID = self.thumbnailRequestID {
            PHCachingImageManager.default().cancelImageRequest(thumbnailRequestID)
        }
        cancelBackgroundTaskIfNeed()
    }

    internal func cancelBackgroundTaskIfNeed() {
        guard taskID != .invalid else { return }
        lock.exec {
            guard self.taskID != .invalid else { return }
            UIApplication.shared.endBackgroundTask(self.taskID)
            self.taskID = .invalid
        }
    }
}
