//
//  SystemInfoTableViewController.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/20.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import SwiftyJSON

class SystemInfoTableViewController: UITableViewController {
    
    let realm = try! Realm()
    var currentUser: UserAccount?
    var systemInfos: List<UserSystemRequest>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 90
        tableView.register(UINib(nibName: "SystemInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "systemInfoTableViewCell")
        systemInfos = currentUser!.userSystemRequests
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return systemInfos!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "systemInfoTableViewCell", for: indexPath) as! SystemInfoTableViewCell
        cell.selectionStyle = .none
        cell.systemInfoLabel.text = systemInfos![indexPath.row].requestMsg
        cell.systemInfoImageView.image = UIImage(data: systemInfos![indexPath.row].requestImage)
        cell.newContactName = systemInfos![indexPath.row].requestName
        cell.newContactEmail = systemInfos![indexPath.row].requestEmail
        
        cell.acceptButtonPressedCallback = {
            let userContact = UserContact()
            userContact.contactNickname = cell.newContactName
            userContact.contactEmail = cell.newContactEmail
            userContact.contactImage = self.systemInfos![indexPath.row].requestImage
            
            self.saveContactToRealm(userContact: userContact, index: indexPath.row)
            self.saveContactToFirebase(contactEmail: userContact.contactEmail)
            self.deleteRequestFromSystemRequestQueue(index: indexPath.row)
            self.configureTabItems()
        }
        cell.ignoreButtonPressedCallback = {
            print("ignore")
        }
        return cell
    }
    
    func saveContactToRealm(userContact: UserContact, index: Int) {
        deleteRequestFromFirebaseQueue(index: index)
        do {
            try realm.write {
                currentUser!.userContacts.append(userContact)
            }
        } catch {
            print(error)
        }
    }
    
    func saveContactToFirebase(contactEmail: String) {
        Database.database().reference().child("Contacts").observeSingleEvent(of: .value) { (snapshot) in
            let data = JSON(snapshot.value!)
            var friendsArray = data[self.emailFormatModifier(email: self.currentUser!.userEmail)].arrayObject == nil ?
                                    [String]() : data[self.emailFormatModifier(email: self.currentUser!.userEmail)].arrayObject as! [String]
            friendsArray.append(contactEmail)
            Database.database().reference().child("Contacts").updateChildValues([self.emailFormatModifier(email: self.currentUser!.userEmail): friendsArray])
        }
        Database.database().reference().child("Contacts").observeSingleEvent(of: .value) { (snapshot) in
            let data = JSON(snapshot.value!)
            var friendsArray = data[self.emailFormatModifier(email: contactEmail)].arrayObject == nil ?
                [String]() : data[self.emailFormatModifier(email: contactEmail)].arrayObject as! [String]
            friendsArray.append(self.currentUser!.userEmail)
            Database.database().reference().child("Contacts").updateChildValues([self.emailFormatModifier(email: contactEmail): friendsArray])
        }
    }
    
    func deleteRequestFromSystemRequestQueue(index: Int) {
        do {
            try realm.write {
                currentUser!.userSystemRequests.remove(at: index)
                self.tableView.reloadData()
            }
        } catch {
            print(error)
        }
    }
    
    func deleteRequestFromFirebaseQueue(index: Int) {
        Database.database().reference().child("NewFriendRequest").child(emailFormatModifier(email: Auth.auth().currentUser!.email!))
            .observeSingleEvent(of: .value) { (snapshot) in
                let data = JSON(snapshot.value!)
                var fromArray = data["from"].arrayObject as! [String]
                let from = fromArray[index]
                Database.database().reference().child("NewFriendRequest").child(self.emailFormatModifier(email: from))
                    .observeSingleEvent(of: .value) { (snapshot) in
                        let data = JSON(snapshot.value!)
                        var toArray = data["to"].arrayObject as! [String]
                        let toIndex = toArray.index(of: Auth.auth().currentUser!.email!)
                        toArray.remove(at: toIndex!)
                        Database.database().reference().child("NewFriendRequest").child(self.emailFormatModifier(email: from)).updateChildValues(["to": toArray])
                }
                fromArray.remove(at: index)
                Database.database().reference().child("NewFriendRequest").child(self.emailFormatModifier(email: Auth.auth().currentUser!.email!)).updateChildValues(["from": fromArray])
        }
    }
    
    func emailFormatModifier(email: String) -> String {
        let modifiedEmail = email.replacingOccurrences(of: ".", with: "*")
        return modifiedEmail
    }
    
    func configureTabItems() {
        tabBarController?.tabBar.items![3].badgeValue = String(currentUser!.userSystemRequests.count)
        if tabBarController?.tabBar.items![3].badgeValue == "0" {
            tabBarController?.tabBar.items![3].badgeValue = nil
        }
    }
    
}
