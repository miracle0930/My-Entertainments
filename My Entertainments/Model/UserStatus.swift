////
////  UserModel.swift
////  My Entertainments
////
////  Created by 管 皓 on 2018/1/27.
////  Copyright © 2018年 Hao Guan. All rights reserved.
////
//
//import Foundation
//
//class UserStatus: NSObject, NSCoding {
//
//    private var username: String?
//    private var password: String?
//    private var login: Bool?
//
//    required init(coder aDecoder: NSCoder) {
//        self.name = aDecoder.decodeObject(forKey: "username") as? String ?? ""
//        self.password = aDecoder.decodeObject(forKey: "password") as? String ?? ""
//        self.login = aDecoder.decodeObject(forKey: "login") as? Bool ?? false
//    }
//
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(username, forKey: "username")
//        aCoder.encode(password, forKey: "password")
//        aCode.encode(login, forKey: "login")
//    }
//
//    func setUserAccount(username: String, password: String) {
//        self.username = username
//        self.password = password
//    }
//
//    func setLogin(login: Bool) {
//        self.login = login
//    }
//
////    func login() -> Bool {
//        return login
//    }
//
//
//
//
//}

