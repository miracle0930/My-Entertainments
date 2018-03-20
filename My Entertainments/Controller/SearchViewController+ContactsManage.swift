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

extension SearchViewController {
    
    func newFriendRequestReceived() {
        Database.database().reference().child("NewFriendRequest").child(emailFormatModifier(email: Auth.auth().currentUser!.email!)).observe(.childChanged) { (snapshot) in
            let data = JSON(snapshot.value!)
            self.tabBarController?.tabBar.items![3].badgeValue = "1"
            do {
                try self.realm.write {
                    let friendRequest = UserSystemRequest()
                    friendRequest.requestMsg = "New Friend Request from \(data)."
                    friendRequest.requestImage = UIImageJPEGRepresentation(UIImage(named: "noimg")!, 1)!
                    self.currentUser!.userSystemRequests.append(friendRequest)
                }
            } catch {
                print(error)
            }
            
        }
    }
    
}
