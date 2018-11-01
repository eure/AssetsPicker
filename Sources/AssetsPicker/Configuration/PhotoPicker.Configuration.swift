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
        }
        
        public enum SelectionMode {
            case single
            case multiple(limit: Int)
        }
        
        /// Single of multiple select
        public var selectionMode: SelectionMode = .single
        
        /// Color of asset selection
        public var selectionColor: UIColor = .red
        
        /// Color of asset selection
        public var tintColor: UIColor = .green
        
        /// Color of asset selection
        public var numberOfItemsInRow = 3
        
        /// Localization of buttons
        public var localize = LocalizedStrings()
        
        /// Custom cells
        public var cellRegistrator = CellRegistrator()
        
        /// Custom header view for assets collection
        public var headerView: UIView?
        
        public var supportOnlyMediaType: [PHAssetMediaType] = [.image, .video]
        
        /// Custom header view for assets collection
        public var isHeaderFloating = false
        
        public init() {}
    }
}

