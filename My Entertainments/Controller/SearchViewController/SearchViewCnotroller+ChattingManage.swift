//
//  SearchViewCnotroller+ChattingManage.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/23.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON
import Firebase

extension SearchViewController {
    
    func newMsgReceived() {
        
        databaseRef.child("Chats").child(emailFormatModifier(email: currentUser!.userEmail)).observe(.childChanged) { (snapshot) in
            print(snapshot)
        }
        
        
    }
    
    
}
