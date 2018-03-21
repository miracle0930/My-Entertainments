//
//  SearchViewController+ContactsManage.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/19.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import Foundation
import Firebase
import RealmSwift
import SwiftyJSON
import SDWebImage

extension SearchViewController {
    
    func newFriendRequestReceived() {
        Database.database().reference().child("NewFriendRequest").child(emailFormatModifier(email: Auth.auth().currentUser!.email!)).observe(.childChanged) { (snapshot) in
            let data = JSON(snapshot.value!).stringValue
            Database.database().reference().child("Users").child(self.emailFormatModifier(email: data)).observeSingleEvent(of: .value) { (snapshot) in
                let requestSender = JSON(snapshot.value!)
                self.tabBarController?.tabBar.items![3].badgeValue = String(self.currentUser!.userSystemRequests.count + 1)
                do {
                    try self.realm.write {
                        let friendRequest = UserSystemRequest()
                        friendRequest.requestMsg = "Hi, I'm '\(requestSender["userNickname"].stringValue)'."
                        friendRequest.requestName = requestSender["userNickname"].stringValue
                        friendRequest.requestEmail = requestSender["userEmail"].stringValue
                        if let dataImage = try? Data(contentsOf: URL(string: requestSender["userPhoto"].stringValue)!) {
                            friendRequest.requestImage = dataImage
                        }
                        self.currentUser!.userSystemRequests.insert(friendRequest, at: 0)
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
}
