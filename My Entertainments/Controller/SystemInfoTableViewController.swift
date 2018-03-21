//
//  SystemInfoTableViewController.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/20.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit
import RealmSwift

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
            print("accept")
            let userContact = UserContact()
            userContact.contactNickname = cell.newContactName
            userContact.contactEmail = cell.newContactEmail
            userContact.contactImage = self.systemInfos![indexPath.row].requestImage
            self.saveContactToRealm(userContact: userContact)
            self.deleteRequestFromSystemRequestQueue(index: indexPath.row)
        }
        cell.ignoreButtonPressedCallback = {
            print("ignore")
        }
        return cell
    }
    
    func saveContactToRealm(userContact: UserContact) {
        do {
            try realm.write {
                print("here")
                currentUser!.userContacts.append(userContact)
                print(currentUser!.userContacts)
            }
        } catch {
            print(error)
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

}
