//
//  ChattingMsgDelegate.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/28.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import Foundation

protocol ChattingMsgDelegate: class {
    
    /*
     business logic when receive new msg from contact you are chatting with
    */
    func newMsgReceivedFromExistedContact()
    
    
    /*
     business logic when reveive new msg from new contact (a new chat window)
    */
    func newMsgReceivedFromNewContact()
    
    

    
    
    
}
