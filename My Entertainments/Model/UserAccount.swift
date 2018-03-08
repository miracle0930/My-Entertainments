//
//  User.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/2/16.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import Foundation
import RealmSwift


class UserAccount: Object {
    @objc dynamic var userId = UUID().uuidString
    @objc dynamic var userNickname = ""
    @objc dynamic var userIntro = ""
    @objc dynamic var userPhoto = Data()
    var userStoredMovies = List<String>()
    var userStoredMusics = List<String>()
    
    override static func primaryKey() -> String? {
        return "userId"
    }
    
}
