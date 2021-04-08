//
//  AssetPickerPresenter.swift
//  MosaiqueAssetsPicker
//
//  Created by Antoine Marandon on 27/08/2020.
//  Copyright © 2020 eureka, Inc. All rights reserved.
//

import Foundation
import Photos
import PhotosUI

/// Use this class to present the default `PHPickerViewController` instead of `MosaiqueAssetPicker` if available.
public final class MosaiqueAssetPickerPresenter: PHPickerViewControllerDelegate {
    private weak var delegate: MosaiqueAssetPickerDelegate?
    private let configuration: MosaiqueAssetPickerConfiguration
    private var assetFutures: [AssetFuture]?

    public static func controller(delegate: MosaiqueAssetPickerDelegate, configuration: MosaiqueAssetPickerConfiguration = .init()) -> UIViewController {
        Self(delegate: delegate, configuration: configuration).controller()
    }

    private init(delegate: MosaiqueAssetPickerDelegate, configuration: MosaiqueAssetPickerConfiguration) {
        self.delegate = delegate
        self.configuration = configuration
    }

    private func controller() -> UIViewController {
        if #available(iOS 14, *) {
            let controller = PHPickerViewController(configuration: configuration.assetPickerConfiguration)
            controller.delegate = self
            objc_setAssociatedObject(controller, Unmanaged.passUnretained(self).toOpaque(), self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return controller
        }
        let controller = MosaiqueAssetPickerViewController()
        controller.configuration = configuration
        controller.pickerDelegate = delegate
        return controller
    }

    @available(iOS 14, *)
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let dispatchGroup = DispatchGroup()
        var images: [UIImage] = []
        var assetFutures: [AssetFuture] = []
        for result in results {
            dispatchGroup.enter()
            assetFutures.append(AssetFuture(pickerResult: result) { imageResult in
                switch imageResult {
                case let .success(image):
                    DispatchQueue.main.async {
                        images.append(image)
                    }
                case .failure:
                    break
                }
                dispatchGroup.leave()
            })
        }
        self.assetFutures = assetFutures
        delegate?.photoPicker(picker, didPickAssets: assetFutures)

        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            if images.isEmpty {
                self?.delegate?.photoPickerDidCancel(picker)
            } else {
                self?.delegate?.photoPicker(picker, didPickImages: images)
            }
        }
    }
}
