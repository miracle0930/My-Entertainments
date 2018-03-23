//
//  ChattingViewController.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/22.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

class ChattingViewController: UIViewController {

    let realm = try! Realm()
    let databaseRef = Database.database().reference()
    
    var currentUser: UserAccount?
    var friendEmail: String?
    var friendName: String?
    var friendPhoto: Data?
    
    @IBOutlet var msgInputView: UIView!
    @IBOutlet var chattingTableView: UITableView!
    @IBOutlet var textInputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        navigationItem.title = friendName!
        chattingTableView.delegate = self
        chattingTableView.dataSource = self

        currentUser = realm.object(ofType: UserAccount.self, forPrimaryKey: Auth.auth().currentUser!.uid)
        chattingTableView.register(UINib(nibName: "UserChatTableViewCell", bundle: nil), forCellReuseIdentifier: "userChatTableViewCell")
        chattingTableView.register(UINib(nibName: "ContactChatTableViewCell", bundle: nil), forCellReuseIdentifier: "contactChatTableViewCell")
//        chattingTableView.rowHeight = 60
        chattingTableView.separatorStyle = .none
    }
    
    @IBAction func voiceButtonPressed(_ sender: UIButton) {
        do {
            try realm.write {
                let friendChatting = UserChattingLog()
                friendChatting.fromUser = false
                friendChatting.content = "Welcome from your friend!"
                currentUser!.userChattingLogs.append(friendChatting)
            }
        } catch {
            print(error)
        }
        chattingTableView.reloadData()
    }
    
    @IBAction func moreButtonPressed(_ sender: UIButton) {
        
        do {
            try realm.write {
                let userChatting = UserChattingLog()
                userChatting.fromUser = true
                userChatting.content = "Welcom from me! Welcom from me! Welcom from me! Welcom from me! Welcom from me! Welcom from me! Welcom from me! Welcom from me!"
                currentUser!.userChattingLogs.append(userChatting)
            }
        } catch {
            print(error)
        }
        chattingTableView.reloadData()

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ChattingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUser!.userChattingLogs.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentUser!.userChattingLogs[indexPath.row].fromUser {
            let cell = chattingTableView.dequeueReusableCell(withIdentifier: "userChatTableViewCell", for: indexPath) as! UserChatTableViewCell
            cell.userImageView.image = UIImage(data: currentUser!.userPhoto)
            cell.userChatContent.text = currentUser!.userChattingLogs[indexPath.row].content
            
            return cell
        } else {
            let cell = chattingTableView.dequeueReusableCell(withIdentifier: "contactChatTableViewCell", for: indexPath) as! ContactChatTableViewCell
            cell.contactImageView.image = UIImage(data: friendPhoto!)
            cell.contactChatContent.text = currentUser!.userChattingLogs[indexPath.row].content
            return cell
        }
    }
}



