//
//  Dynamic.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/18.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation

class Observable<T> {
    var value: T {
        didSet {
            // notify observers
            for linkBox in linksBoxes {
                linkBox.link?.observerNotify(value)
            }
        }
    }
    
    // should be private
    private var linksBoxes: [LinkBox<T>] = []
    
    func append(linkBox: LinkBox<T>) {
        self.linksBoxes.append(linkBox)
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func purge() {
        linksBoxes = []
    }
}
