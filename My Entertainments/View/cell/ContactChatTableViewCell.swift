//
//  ContactChatTableViewCell.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/21.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit

class ContactChatTableViewCell: UITableViewCell {
    
    @IBOutlet var contactImageView: UIImageView!
    @IBOutlet var contactChatContent: UITextView!
    @IBOutlet var contactChatContentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contactChatContentView.layer.cornerRadius = 10
        contactChatContentView.layer.masksToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
