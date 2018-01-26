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
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
//            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                let currentUser = result.first as! NSManagedObject
                currentUser.setValue(false, forKey: "login")
            }
            self.tabBarController?.tabBar.isHidden = true
            performSegue(withIdentifier: "userlogout", sender: self)
            
        } catch {
            print("error")
        }
    }
}
