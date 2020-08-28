//
//  PhotoPicker.Configuration.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/16.
//  Copyright © 2018 eureka, Inc. All rights reserved.
//

import Foundation
import UIKit
import enum Photos.PHAssetMediaType
import PhotosUI

public enum SelectionMode {
    case single
    case multiple(limit: Int)
    
    // Introspection
    enum Case {
      case single
      case multiple
    }
    var `case`: Case {
    switch self {
        case .single: return .single
        case .multiple: return .multiple
        }
    }
}

public struct LocalizedStrings {
    public var done: String = "Done"
    public var next: String = "Next"
    public var dismiss: String = "Dismiss"
    public var changePermissions: String = "Change your Photo Library permissions"
    
    public init() {}
}

public struct MosaiqueAssetPickerConfiguration {

    /// false if you want to skip the "done" button for single asset selection

    var singleSelectionNeedsConfirmation = true

    /// Single of multiple select
    var selectionMode: SelectionMode = .single
    
    /// Color of asset selection
    var selectionColor: UIColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
    
    /// Tint color used for navigation items color ( done button, etc )
    var tintColor: UIColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
    
    /// Number of items in a row for the assets list within an asset collection
    var numberOfItemsPerRow = 3
    
    /// Localization of buttons
    var localize = LocalizedStrings()
    
    /// Custom cells
    var cellRegistrator = AssetPickerCellRegistrator()
    
    /// Custom cell spacing
    var cellSpacing: CGFloat = 2
    
    /// Custom header view for assets collection
    var headerView: UIView?
    
    /// The media type that will be displayed
    var supportOnlyMediaTypes: [PHAssetMediaType] = [.image]
    
    /// Set this property to true if you want to disable animations when scrolling through the assets
    var disableOnLibraryScrollAnimation = false
    
    /// Custom header view for assets collection
    var isHeaderFloating = false

    @available(iOS 14, *)
    var assetPickerConfiguration: PHPickerConfiguration {
        var configuation = PHPickerConfiguration()
        configuation.filter = {
            if supportOnlyMediaTypes.count > 1 {
                return nil
            }
            switch supportOnlyMediaTypes[0] {
            case .unknown, .audio:
                assertionFailure("Unsupported types")
                return nil
            case .image:
                return .images
            case .video:
                return .videos
            @unknown default:
                assertionFailure("Unsupported types")
                return nil
            }
        }()
        configuation.selectionLimit = {
            switch selectionMode {
            case .single:
                return 1
            case .multiple(limit: let limit):
                return limit
            }
        }()
        return configuation
    }

    public init() {}
}

