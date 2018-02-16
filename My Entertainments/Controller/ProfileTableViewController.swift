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
    let profileCache = SharedImageCache.getSharedImageCache()
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
        let profileRef = self.storageRef.child("entertainments/\(Auth.auth().currentUser!.uid)/profile")
        if let cachedImage = self.profileCache.object(forKey: "profile" as NSString) as Data? {
            print("here")
            self.userPhotoImageView.image = UIImage(data: cachedImage)
        } else {
            profileRef.downloadURL { (url, error) in
                if error == nil {
                    let placeholderImage = UIImage(named: "defaultphoto")
                    self.userPhotoImageView.sd_setImage(with: url, placeholderImage: placeholderImage, completed: { (_, _, _, _) in
                        let profileImage = self.userPhotoImageView.image
                        if let imageData = UIImagePNGRepresentation(profileImage!) {
                            self.profileCache.setObject(imageData as NSData, forKey: "profile" as NSString)
                        }
                    })
                    
                } else {
                    print(error.debugDescription)
                }
            }
        }
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
