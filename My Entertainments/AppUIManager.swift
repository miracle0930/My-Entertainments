////
////  ReloadUserInterface.swift
////  My Entertainments
////
////  Created by 管 皓 on 2018/3/21.
////  Copyright © 2018年 Hao Guan. All rights reserved.
////
//
//import Foundation
//import RealmSwift
//import SwiftyJSON
//import Firebase
//
//class AppUIManager {
//
//    static let realm = try! Realm()
//    static let databaseRef = Database.database().reference()
//    static let storageRef = Storage.storage().reference()
//
////    lazy static func reloadUserInterface() {
////        databaseRef.child("NewFriendRequest").child(emailFormatModifier(email: Auth.auth().currentUser!.email!)).observeSingleEvent(of: .value) { (snapshot) in
////
////        }
////
////
////    }
//
//    static func reloadNewMsgNumFromSystem() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let tabBarController = storyboard.
//        tabBarController?.tabBar.items![3].badgeValue = String(currentUser!.userSystemRequests.count)
//        if tabBarController?.tabBar.items![3].badgeValue == "0" {
//            tabBarController?.tabBar.items![3].badgeValue = nil
//        }
//    }
//
//    static func emailFormatModifier(email: String) -> String {
//        let modifiedEmail = email.replacingOccurrences(of: ".", with: "*")
//        return modifiedEmail
//    }
//
//
//
//
//}
//
