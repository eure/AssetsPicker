//
//  SelectionContainer.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/19.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import Photos

public protocol ItemIdentifier {
    associatedtype Identifier : Hashable

    var identifier: Self.Identifier { get }
}

public final class SelectionContainer<T: ItemIdentifier> {
    
    // MARK: Properties
    
    private(set) var selectedItems: Observable<[T]> = Observable<[T]>([])
    private(set) var size: Int
    
    var selectedCount: Int {
        return selectedItems.value.count
    }
    
    var isEmpty: Bool {
        return selectedItems.value.isEmpty
    }
    
    var isFilled: Bool {
        return !(selectedItems.value.count < size)
    }
    
    // MARK: Lifecycle
    
    init(withSize size: Int) {
        self.size = size
    }
    
    func item(for key: T.Identifier) -> T? {
        let items = selectedItems.value
        return items.index(where: { $0.identifier == key }).map { items[$0] }
    }
    
    func append(item: T, removeFirstIfAlreadyFilled: Bool = false) {
        guard !selectedItems.value.contains(where: { $0.identifier == item.identifier }) else { return }
        
        if isFilled {
            if removeFirstIfAlreadyFilled {
                let items = selectedItems.value
                selectedItems.value = items.dropFirst() + [item]
            }
        } else {
            selectedItems.value.append(item)
        }
    }
    
    func remove(item: T) {
        var items = selectedItems.value
        
        guard let index = items.index(where: { $0.identifier == item.identifier }) else { return }
        
        items.remove(at: index)
        
        selectedItems.value = items
    }
    
    func purge() {
        selectedItems.value = []
    }
}
