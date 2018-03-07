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
    @objc dynamic var username: String = ""
    @objc dynamic var userPhoto = Data()
    @objc dynamic var userIntro = ""
    var userStoredMovies = List<String>()
    var userStoredMusics = List<String>()
}
