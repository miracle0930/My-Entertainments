//
//  ProfileViewController.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/1/22.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class ProfileViewController: UIViewController {
    
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Profile"

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            userDefault.set(false, forKey: "login")
            self.tabBarController?.tabBar.isHidden = true
            performSegue(withIdentifier: "userlogout", sender: self)
        } catch {
            print("error")
        }
    }
}
