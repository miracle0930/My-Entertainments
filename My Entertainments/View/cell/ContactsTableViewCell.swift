//
//  ContactsTableViewCell.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/14.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {
    
    @IBOutlet var contactImageView: UIImageView!
    @IBOutlet var contactNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
