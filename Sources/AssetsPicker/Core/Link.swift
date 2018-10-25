//
//  Link.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/18.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation

class Link<T> {
    typealias Listener = (T) -> Void

    var observerNotify: Listener
    
    init(_ listener: @escaping Listener) {
        self.observerNotify = listener
    }
    
    func bind(data: Observable<T>) {
        data.append(linkBox: LinkBox(self))
        observerNotify(data.value)
    }
}

class LinkBox<T> {
    weak var link: Link<T>?
    init(_ link: Link<T>) {
        self.link = link
    }
}
