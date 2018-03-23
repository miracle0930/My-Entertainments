//
//  UserChatTableViewCell.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/21.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit

class UserChatTableViewCell: UITableViewCell {
    
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userChatContent: UITextView!
    @IBOutlet var userChatContentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userChatContentView.layer.cornerRadius = 10
        userChatContentView.layer.masksToBounds = true
        let contentSize = userChatContent.sizeThatFits(userChatContent.bounds.size)
        var frame = userChatContent.frame
        frame.size.height = contentSize.height
        userChatContent.frame = frame
        self.frame = frame
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
