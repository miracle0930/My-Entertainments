//
//  SystemMessageDelegate.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/25.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import Foundation

protocol SystemMessageDelegate: class {
    
    /*
     Send notification to user when receive new friend request.
    */
    func newFriendRequestReceived()
    
    /*
     Users are added to each's contacts when the request is accepted.
    */
    func requestHasBeenAccepted()
    
}
