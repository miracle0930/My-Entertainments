//
//  ChatLog.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/22.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import Foundation
import RealmSwift

class UserChattingLog: Object {
    @objc dynamic var content = ""
    @objc dynamic var fromUser = false
    @objc dynamic var time = ""
    var chattingLogHolder = LinkingObjects(fromType: UserAccount.self, property: "userChattingLogs")
}
