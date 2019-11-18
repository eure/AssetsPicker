//
//  Lock.swift
//  AssetsPicker
//
//  Created by Antoine Marandon on 18/11/2019.
//  Copyright © 2019 eure. All rights reserved.
//

import Foundation

class Lock {
    class func exec<T>(lock: AnyObject!, proc: () -> T) -> T {
        let result = proc()
        objc_sync_exit(lock as Any)
        return result
    }
}
