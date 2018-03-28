//
//  UserContact.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/14.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import Foundation
import RealmSwift

class UserContact: Object {
    @objc dynamic var contactNickname = ""
    @objc dynamic var contactEmail = ""
    @objc dynamic var contactIntro = ""
    @objc dynamic var contactImage = Data()
    @objc dynamic var contactName = ""
    var contactsDataHolder = LinkingObjects(fromType: UserAccount.self, property: "userContacts")
}
