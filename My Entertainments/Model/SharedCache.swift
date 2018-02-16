//
//  CacheSingleton.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/2/15.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import Foundation

class SharedImageCache: NSCache<NSString, NSData> {
    
    static let sharedImageCache = SharedImageCache()
    static func getSharedImageCache() -> SharedImageCache {
        return sharedImageCache
    }

}
