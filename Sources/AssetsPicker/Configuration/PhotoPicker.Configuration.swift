//
//  PhotoPicker.Configuration.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/16.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import UIKit
import enum Photos.PHAssetMediaType

extension PhotosPicker {
    public struct Configuration {
        
        internal static var shared = PhotosPicker.Configuration()
        
        public struct LocalizedStrings {
            public var done: String = "Done"
            public var next: String = "Next"
            public var dismiss: String = "Dismiss"
            public var collections: String = "Collections"
            public var changePermissions: String = "Change your Photo Library permissions"
        }
        
        public enum SelectionMode {
            case single
            case multiple(limit: Int)
        }
        
        /// Single of multiple select
        public var selectionMode: SelectionMode = .multiple(limit: 3)
        
        /// Color of asset selection
        public var selectionColor: UIColor = #colorLiteral(red: 0.4156862745, green: 0.768627451, blue: 0.8117647059, alpha: 1)
        
        /// Tint color used for navigation items color ( done button, etc )
        public var tintColor: UIColor = #colorLiteral(red: 0.4156862745, green: 0.768627451, blue: 0.8117647059, alpha: 1)
        
        /// Number of items in a row for the assets list within an asset collection
        public var numberOfItemsInRow = 3
        
        /// Localization of buttons
        public var localize = LocalizedStrings()
        
        /// Custom cells
        public var cellRegistrator = CellRegistrator()
        
        /// Custom header view for assets collection
        public var headerView: UIView?
        
        /// The media type that will be displayed
        public var supportOnlyMediaType: [PHAssetMediaType] = [.image]
        
        /// Set this property to true if you want to disable animations when scrolling through the assets
        public var disableOnLibraryScrollAnimation = false
        
        /// Custom header view for assets collection
        public var isHeaderFloating = false
        
        public init() {}
    }
}

