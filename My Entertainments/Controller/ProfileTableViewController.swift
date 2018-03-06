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
import SDWebImage


class ProfileTableViewController: UITableViewController {
    
    let userDefault = UserDefaults.standard
    
    @IBOutlet var userPhotoImageView: UIImageView!
    @IBOutlet var userNickname: UILabel!
    @IBOutlet var userEmail: UILabel!
    let storageRef = Storage.storage().reference()
    let databaseRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Profile"
        let user = Auth.auth().currentUser!
        userEmail.text = "Email: " + user.email!
        databaseRef.child("Users").child(user.uid).observeSingleEvent(of: .value) { (snapshot) in
            let userData = JSON(snapshot.value!)
            self.userNickname.text = userData["Account"]["userNickname"].stringValue
        }
        userPhotoImageView.contentMode = .scaleAspectFit
    }
    
    func configureUserPhoto() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        configureUserPhoto()

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
