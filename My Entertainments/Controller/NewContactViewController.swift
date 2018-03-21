//
//  NewContactViewController.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/14.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON

class NewContactViewController: UIViewController {
    
    var newContactName: String?
    var newContactIntro: String?
    var newContactImageUrl: String?
    var newContactEmail: String?
    var currentUser: UserAccount?
    let storageRef = Storage.storage()
    let databaseRef = Database.database().reference()
    

    @IBOutlet var newContactImageView: UIImageView!
    @IBOutlet var newContactNameLabel: UILabel!
    @IBOutlet var newContactIntroTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newContactNameLabel.text = newContactName
        newContactIntroTextView.text = newContactIntro
        let pathReference = storageRef.reference(forURL: newContactImageUrl!)
        pathReference.downloadURL { (url, error) in
            if error == nil {
                self.newContactImageView.sd_setImage(with: url, completed: nil)
            }
        }
    }
    
    @IBAction func sendRequestButtonPressed(_ sender: UIButton) {
        databaseRef.child("NewFriendRequest").child(emailFormatModifier(email: newContactEmail!)).observeSingleEvent(of: .value) { (snapshot) in
            let data = JSON(snapshot.value!)
            var requestArray = data["from"].arrayObject == nil ? [String]() : data["from"].arrayObject as! [String]
            if !requestArray.contains(Auth.auth().currentUser!.email!) {
                requestArray.append(Auth.auth().currentUser!.email!)
                self.databaseRef.child("NewFriendRequest")
                    .child(self.emailFormatModifier(email: self.newContactEmail!))
                    .updateChildValues(["from": requestArray])
            }
        }
        databaseRef.child("NewFriendRequest").child(emailFormatModifier(email: Auth.auth().currentUser!.email!)).observeSingleEvent(of: .value) { (snapshot) in
            let data = JSON(snapshot.value!)
            var requestArray = data["to"].arrayObject == nil ? [String]() : data["to"].arrayObject as! [String]
            if !requestArray.contains(self.newContactEmail!) {
                requestArray.append(self.newContactEmail!)
                self.databaseRef.child("NewFriendRequest").child(self.emailFormatModifier(email: Auth.auth().currentUser!.email!)).updateChildValues(["to": requestArray])
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func emailFormatModifier(email: String) -> String {
        let modifiedEmail = email.replacingOccurrences(of: ".", with: "*")
        return modifiedEmail
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
