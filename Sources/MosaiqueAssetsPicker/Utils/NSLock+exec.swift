//
//  Lock.swift
//  AssetsPicker
//
//  Created by Antoine Marandon on 18/11/2019.
//  Copyright © 2019 eureka, Inc. All rights reserved.
//

#if os(iOS)
import Foundation

extension NSLock {
    func exec<T>(proc: () -> T) -> T {
        lock()
        let result = proc()
        unlock()
        return result
    }
}
#endif
