//
//  ContactsTableViewController.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/14.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import SwiftyJSON
import Alamofire

class ContactsTableViewController: UITableViewController, UITextFieldDelegate {
    
    let realm = try! Realm()
    let databaseRef = Database.database().reference()
    
    var searchField: UITextField!
    var newContactJSON: JSON!
    var currentUser: UserAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 70
        tableView.register(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "contactsTableViewCell")
        currentUser = realm.object(ofType: UserAccount.self, forPrimaryKey: Auth.auth().currentUser!.uid)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addNewFriendButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Friend", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            self.searchField = textField
            self.searchField.delegate = self
        }
        
        let search = UIAlertAction(title: "Search", style: .default) { (action) in
            self.databaseRef.child("Users").child(self.emailFormatModifier(email: self.searchField.text!)).observeSingleEvent(of: .value, with: { (snapshot) in
                let rawValue = JSON(snapshot.value!)
                if rawValue != JSON.null {
                    self.newContactJSON = rawValue
                    self.performSegue(withIdentifier: "findNewContact", sender: self)
                }
            })
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(search)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "findNewContact" {
            let destination = segue.destination as! NewContactViewController
            destination.newContactName = newContactJSON["userNickname"].stringValue
            destination.newContactIntro = newContactJSON["userIntro"].stringValue
            destination.newContactImageUrl = newContactJSON["userPhoto"].stringValue
            destination.newContactEmail = self.searchField.text!
            destination.currentUser = currentUser!
        } else if segue.identifier == "showSystemMessages" {
            let destination = segue.destination as! SystemInfoTableViewController
            destination.currentUser = currentUser!
        } else if segue.identifier == "contactsToChat" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as! ChattingViewController
                destination.currentUser = currentUser!
                destination.friendName = currentUser!.userContacts[indexPath.row].contactNickname
                destination.friendPhoto = currentUser!.userContacts[indexPath.row].contactImage
                destination.friendEmail = currentUser!.userContacts[indexPath.row].contactEmail
            }
        }
    }
    
    func emailFormatModifier(email: String) -> String {
        if email == "" {
            return " "
        }
        let modifiedEmail = email.replacingOccurrences(of: ".", with: "*")
        return modifiedEmail
    }
    


    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUser!.userContacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactsTableViewCell", for: indexPath) as! ContactsTableViewCell
        cell.contactImageView.image = UIImage(data: currentUser!.userContacts[indexPath.row].contactImage)
        cell.contactNameLabel.text = currentUser!.userContacts[indexPath.row].contactNickname
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: "showSystemMessages", sender: self)
        } else {
            performSegue(withIdentifier: "contactsToChat", sender: self)
        }
    }
    
    
}
