//
//  SystemInfo.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/20.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import Foundation
import RealmSwift

class UserSystemRequest: Object {
    @objc dynamic var requestMsg = ""
    @objc dynamic var requestImage = Data()
    @objc dynamic var requestName = ""
    @objc dynamic var requestEmail = ""
    var requestsDataHolder = LinkingObjects(fromType: UserAccount.self, property: "userSystemRequests")
}
