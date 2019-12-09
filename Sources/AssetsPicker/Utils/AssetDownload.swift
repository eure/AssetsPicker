//
//  AssetDownload.swift
//  AssetsPicker
//
//  Created by Antoine Marandon on 09/12/2019.
//  Copyright © 2019 eure. All rights reserved.
//

import Foundation
import Photos

public class AssetDownload {
    public let asset: PHAsset
    public var completionBlock: ((UIImage?) -> Void)? {
        didSet {
            lock.exec {
                if hasSetImage {
                    completionBlock?(finalImage)
                    completionBlock = nil
                }
            }
        }
    }
    public var thumbnailBlock: ((UIImage?) -> Void)? {
        didSet {
            lock.exec {
                if hasSetThumbnail {
                    thumbnailBlock?(thumbnail)
                    thumbnailBlock = nil
                }
            }
        }
    }
    private var hasSetThumbnail = false
    private var hasSetImage = false
    public internal(set) var thumbnail: UIImage? {
        didSet {
            lock.exec {
                thumbnailBlock?(thumbnail)
                thumbnailRequestID = nil
                hasSetThumbnail = true
            }
        }
    }
    public internal(set) var finalImage: UIImage? {
        didSet {
            lock.exec {
                completionBlock?(finalImage)
                cancelBackgroundTaskIfNeed()
                imageRequestID = nil
                hasSetImage = true
            }
        }
    }
    private let lock = NSLock()
    private var taskID = UIBackgroundTaskIdentifier.invalid
    internal var thumbnailRequestID: PHImageRequestID?
    internal var imageRequestID: PHImageRequestID?

    init(asset: PHAsset) {
        self.asset = asset
        self.taskID = UIApplication.shared.beginBackgroundTask(withName: "AssetPicker.download", expirationHandler: { [weak self] in
            self?.cancelBackgroundTaskIfNeed()
        })
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
        guard self.taskID != .invalid else { return }
        self.lock.exec {
            guard self.taskID != .invalid else { return }
            UIApplication.shared.endBackgroundTask(self.taskID)
            self.taskID = .invalid
        }
    }
}
