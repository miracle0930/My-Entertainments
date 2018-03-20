//
//  SystemInfoTableViewCell.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/20.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit

class SystemInfoTableViewCell: UITableViewCell {

    @IBOutlet var systemInfoImageView: UIImageView!
    @IBOutlet var systemInfoLabel: UILabel!
    var acceptButtonPressedCallback: (() -> ())?
    var ignoreButtonPressedCallback: (() -> ())?
    
    @IBOutlet var acceptButton: UIButton!
    @IBOutlet var ignoreButton: UIButton!
    @IBOutlet var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        acceptButton.layer.cornerRadius = 10
        acceptButton.layer.borderWidth = 1
        ignoreButton.layer.cornerRadius = 10
        ignoreButton.layer.borderWidth = 1

    }
    
    @IBAction func acceptButtonPressed(_ sender: UIButton) {
        acceptButton.isEnabled = false
        ignoreButton.isEnabled = false
        statusLabel.text = "Accepted"
        statusLabel.backgroundColor = UIColor.green
        acceptButtonPressedCallback!()
    }
    
    
    @IBAction func ignoreButtonPressed(_ sender: UIButton) {
        acceptButton.isEnabled = false
        ignoreButton.isEnabled = false
        statusLabel.text = "Ignored"
        statusLabel.backgroundColor = UIColor.gray
        ignoreButtonPressedCallback!()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
