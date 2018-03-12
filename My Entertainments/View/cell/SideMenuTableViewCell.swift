//
//  SideMenuTableViewCell.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/11.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit

class SideMenuTableViewCell: UITableViewCell {

    @IBOutlet var sideButtonImage: UIImageView!
    @IBOutlet var sideButtonLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
