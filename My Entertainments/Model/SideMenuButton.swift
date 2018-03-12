//
//  SideMenuButton.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/12.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import Foundation
import UIKit

class SideButton {
    var sideButtonImage: UIImage?
    var sideButtonLabel: String?
    
    init(sideButtonImage: UIImage, sideButtonLabel: String) {
        self.sideButtonImage = sideButtonImage
        self.sideButtonLabel = sideButtonLabel
    }
}

class SideButtonGenerator {
    static func generateSideButtons() -> [SideButton] {
        var buttons = [SideButton]()
        buttons.append(SideButton(sideButtonImage: UIImage(named: "edit")!, sideButtonLabel: "Edit Profile"))
        buttons.append(SideButton(sideButtonImage: UIImage(named: "exit")!, sideButtonLabel: "Log Out"))
        return buttons
    }
}
