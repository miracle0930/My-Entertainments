//
//  UserStoredData.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/6.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import Foundation
import RealmSwift

class UserStoredData: Object {
    
    @objc dynamic var userPhoto = Data()
    @objc dynamic var userStoredMovies = "" // store movie's id
    @objc dynamic var userStoredMusics = "" // store music's id, if there is
    
    
    var dataHolder = LinkingObjects(fromType: UserAccount.self, property: "userStoredDatas")
    
}
