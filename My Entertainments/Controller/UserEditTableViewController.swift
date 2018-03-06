//
//  UserEditTableViewController.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/1/28.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit

class UserEditTableViewController: UITableViewController {

    @IBOutlet var userProfileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userProfileImageView.contentMode = .scaleAspectFit

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
//        if let cachedImage = self.profileCache.object(forKey: "profile" as NSString) as Data? {
//            self.userProfileImageView.image = UIImage(data: cachedImage)
//        } else {
//            self.userProfileImageView.image = UIImage(named: "defaultphoto")
//        }
    }
    
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            performSegue(withIdentifier: "goToPhotoSet", sender: self)
        }
    }
}
