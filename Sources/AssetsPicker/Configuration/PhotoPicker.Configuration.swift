//
//  PhotoPicker.Configuration.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/16.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import UIKit

extension PhotosPicker {
    public struct Configuration {
        
        internal static var shared = Configuration(selectionMode: .single, headerView: nil)
        
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
        
        
        // config of collection view height and detail number of column
        
        /// Single of multiple select
        public let selectionMode: SelectionMode
        
        /// Display camera option
        public let shouldDisplayCameraOption: Bool
        
        /// Color of asset selection
        public let selectionColor: UIColor
        
        /// Color of asset selection
        public let tintColor: UIColor
        
        /// Color of asset selection
        public let numberOfItemsInRow: Int
        
        /// Localization of buttons
        public var localize: LocalizedStrings = .init()
        
        /// Custom cells
        public var cellRegistrator: CellRegistrator = .init()
        
        /// Custom header view for assets collection
        public let headerView: UIView?
        
        /// Custom header view for assets collection
        public let isHeaderFloating: Bool
        
        public init(
            selectionMode: SelectionMode,
            shouldDisplayCameraOption: Bool = false,
            selectionColor: UIColor = .red,
            tintColor: UIColor = .green,
            numberOfItemsInRow: Int = 3,
            headerView: UIView? = nil,
            isHeaderFloating: Bool = false
            ) {
            self.selectionMode = selectionMode
            self.shouldDisplayCameraOption = shouldDisplayCameraOption
            self.selectionColor = selectionColor
            self.tintColor = tintColor
            self.numberOfItemsInRow = numberOfItemsInRow
            self.headerView = headerView
            self.isHeaderFloating = isHeaderFloating
        }
    }
}

