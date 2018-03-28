//
//  SearchViewCnotroller+ChattingMsgDelegate.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/23.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON
import Firebase

extension SearchViewController: ChattingMsgDelegate {
    
    func newMsgReceivedFromExistedContact() {
        databaseRef.child("Chats").child(emailFormatModifier(email: currentUser!.userEmail)).observe(.childChanged) { (snapshot) in
            
            let data = JSON(snapshot.value!)
            self.writeChattingLogToRealm(data: data)
            
        }
    }
    
    func newMsgReceivedFromNewContact() {
        databaseRef.child("Chats").child(emailFormatModifier(email: currentUser!.userEmail)).observe(.childAdded) { (snapshot) in
            let data = JSON(snapshot.value!)
            self.writeChattingLogToRealm(data: data)
        }
    }
    
    func writeChattingLogToRealm(data: JSON) {
        let chattingLog = UserChattingLog()
        chattingLog.content = data["content"].stringValue
        chattingLog.fromUser = false
        chattingLog.time = data["time"].stringValue
        do {
            try realm.write {
                currentUser!.userChattingLogs.append(chattingLog)
            }
        } catch {
            print(error)
        }
    }
    
   
    
}
