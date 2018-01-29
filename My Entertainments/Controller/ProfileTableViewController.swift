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
import SwiftyJSON


class ProfileTableViewController: UITableViewController {
    
    let userDefault = UserDefaults.standard
    
    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var userNickname: UILabel!
    @IBOutlet var userEmail: UILabel!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Profile"
        ref = Database.database().reference()
        let user = Auth.auth().currentUser!
        userEmail.text = "Email: " + user.email!
        ref.child("Users").child(user.uid).observeSingleEvent(of: .value) { (snapshot) in
            let userData = JSON(snapshot.value!)
            self.userNickname.text = userData["Account"]["userNickname"].stringValue
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
