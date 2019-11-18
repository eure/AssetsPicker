//
//  Lock.swift
//  AssetsPicker
//
//  Created by Antoine Marandon on 18/11/2019.
//  Copyright © 2019 eure. All rights reserved.
//

import Foundation

enum Lock {
    static func exec<T>(lock: AnyObject!, proc: () -> T) -> T {
        objc_sync_enter(lock as Any)
        let result = proc()
        objc_sync_exit(lock as Any)
        return result
    }
}
