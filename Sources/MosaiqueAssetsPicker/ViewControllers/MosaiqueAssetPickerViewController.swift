//
//  PhotosPickerController.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/16.
//  Copyright © 2018 eureka, Inc. All rights reserved.
//

#if os(iOS)
import enum Photos.PHAssetMediaType
import UIKit

public protocol MosaiqueAssetPickerDelegate: AnyObject {
    func photoPicker(_ controller: UIViewController, didPickImages images: [UIImage])
    /// [Optional] Will be called when the user press the done button. At this point, you can either:
    /// - Keep or dissmiss the view controller and continue forward with the `AssetFuture` object
    /// - Wait for the images to be ready (will be provided with by the `didPickImages`
    func photoPicker(_ controller: UIViewController, didPickAssets assets: [AssetFuture])

    func photoPickerDidCancel(_ controller: UIViewController)
}

extension MosaiqueAssetPickerDelegate {
    func photoPicker(_: UIViewController, didPickAssets _: [AssetFuture]) {}
}

public final class MosaiqueAssetPickerViewController: UINavigationController {
    // MARK: - Properties

    var configuration = MosaiqueAssetPickerConfiguration()
    public weak var pickerDelegate: MosaiqueAssetPickerDelegate?
    private var assetFutures: [AssetFuture]?

    // MARK: - Lifecycle

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupRootController: do {
            let controller = SelectAssetCollectionContainerViewController(configuration: configuration)
            pushViewController(controller, animated: false)
        }

        setupPickImagesNotification: do {
            NotificationCenter.assetPicker.addObserver(self,
                                                       selector: #selector(didPickImages(notification:)),
                                                       name: PhotoPickerPickImagesNotificationName,
                                                       object: nil)
            NotificationCenter.assetPicker.addObserver(self,
                                                       selector: #selector(didPickAssets(notification:)),
                                                       name: PhotoPickerPickAssetsNotificationName,
                                                       object: nil)

            NotificationCenter.assetPicker.addObserver(self,
                                                       selector: #selector(didCancel(notification:)),
                                                       name: PhotoPickerCancelNotificationName,
                                                       object: nil)
        }
        setupNavigationBar: do {
            let dismissBarButtonItem = UIBarButtonItem(title: configuration.localize.dismiss, style: .plain, target: self, action: #selector(dismissPicker(sender:)))
            navigationBar.topItem?.leftBarButtonItem = dismissBarButtonItem
            navigationBar.tintColor = configuration.tintColor
        }
    }

    @objc func didPickImages(notification: Notification) {
        if let images = notification.object as? [UIImage] {
            self.pickerDelegate?.photoPicker(self, didPickImages: images)
        }
        assetFutures = nil
    }

    @objc func didCancel(notification _: Notification) {
        self.pickerDelegate?.photoPickerDidCancel(self)
        assetFutures = nil
    }

    @objc func dismissPicker(sender _: Any) {
        NotificationCenter.assetPicker.post(name: PhotoPickerCancelNotificationName, object: nil)
    }

    @objc func didPickAssets(notification: Notification) {
        if let downloads = notification.object as? [AssetFuture] {
            self.pickerDelegate?.photoPicker(self, didPickAssets: downloads)
            assetFutures = downloads
        }
    }
}

// MARK: Builder pattern

public extension MosaiqueAssetPickerViewController {
    @discardableResult
    func setSelectionMode(_ selectionMode: SelectionMode) -> MosaiqueAssetPickerViewController {
        configuration.selectionMode = selectionMode
        return self
    }

    @discardableResult
    func setSelectionMode(_ selectionColor: UIColor) -> MosaiqueAssetPickerViewController {
        configuration.selectionColor = selectionColor
        return self
    }

    @discardableResult
    func setSelectionColor(_ tintColor: UIColor) -> MosaiqueAssetPickerViewController {
        configuration.tintColor = tintColor
        return self
    }

    @discardableResult
    func setNumberOfItemsPerRow(_ numberOfItemsPerRow: Int) -> MosaiqueAssetPickerViewController {
        configuration.numberOfItemsPerRow = numberOfItemsPerRow
        return self
    }

    @discardableResult
    func setCellSpacing(_ spacing: CGFloat) -> MosaiqueAssetPickerViewController {
        configuration.cellSpacing = spacing
        return self
    }

    @discardableResult
    func setHeaderView(_ headerView: UIView, isHeaderFloating: Bool) -> MosaiqueAssetPickerViewController {
        configuration.headerView = headerView
        configuration.isHeaderFloating = isHeaderFloating
        return self
    }

    @discardableResult
    func setCellRegistrator(_ cellRegistrator: AssetPickerCellRegistrator) -> MosaiqueAssetPickerViewController {
        configuration.cellRegistrator = cellRegistrator
        return self
    }

    @discardableResult
    func setMediaTypes(_ supportOnlyMediaType: [PHAssetMediaType]) -> MosaiqueAssetPickerViewController {
        configuration.supportOnlyMediaTypes = supportOnlyMediaType
        return self
    }

    @discardableResult
    func disableOnLibraryScrollAnimation() -> MosaiqueAssetPickerViewController {
        configuration.disableOnLibraryScrollAnimation = true
        return self
    }

    @discardableResult
    func localize(_ localize: LocalizedStrings) -> MosaiqueAssetPickerViewController {
        configuration.localize = localize
        return self
    }
}
#endif
