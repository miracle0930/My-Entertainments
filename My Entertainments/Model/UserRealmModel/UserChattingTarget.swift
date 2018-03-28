//
//  UserChattingTarget.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/28.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import Foundation
import RealmSwift

class UserChattingTarget: Object {
    @objc dynamic var contactEmail = ""
    @objc dynamic var contactPhoto = Data()
    @objc dynamic var contactLastMsg = ""
    @objc dynamic var contactTime = ""
    @objc dynamic var unreadMsgs = 0
    var chattingTargetHolder = LinkingObjects(fromType: UserAccount.self, property: "userChattingTargets")
}
