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

public enum SelectionMode {
    case single
    case multiple(limit: Int)
}

public struct LocalizedStrings {
    public var done: String = "Done"
    public var next: String = "Next"
    public var dismiss: String = "Dismiss"
    public var changePermissions: String = "Change your Photo Library permissions"
    
    public init() {}
}


class MosaiqueAssetPickerConfiguration {
    
    static let shared = MosaiqueAssetPickerConfiguration()
    
    /// Single of multiple select
    public var selectionMode: SelectionMode = .single
    
    /// Color of asset selection
    public var selectionColor: UIColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
    
    /// Tint color used for navigation items color ( done button, etc )
    public var tintColor: UIColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
    
    /// Number of items in a row for the assets list within an asset collection
    public var numberOfItemsPerRow = 3
    
    /// Localization of buttons
    public var localize = LocalizedStrings()
    
    /// Custom cells
    public var cellRegistrator = AssetPickerCellRegistrator()
    
    /// Custom cell spacing
    public var cellSpacing: CGFloat = 2
    
    /// Custom header view for assets collection
    public var headerView: UIView?
    
    /// The media type that will be displayed
    public var supportOnlyMediaTypes: [PHAssetMediaType] = [.image]
    
    /// Set this property to true if you want to disable animations when scrolling through the assets
    public var disableOnLibraryScrollAnimation = false
    
    /// Custom header view for assets collection
    public var isHeaderFloating = false
    
    public init() {}
}

