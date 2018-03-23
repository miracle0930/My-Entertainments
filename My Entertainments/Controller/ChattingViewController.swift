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

class ChattingViewController: UIViewController, UITextViewDelegate {

    let realm = try! Realm()
    let databaseRef = Database.database().reference()
    
    var currentUser: UserAccount?
    var friendEmail: String?
    var friendName: String?
    var friendPhoto: Data?
    var keyboardHeight: CGFloat?
    
    @IBOutlet var msgInputView: UIView!
    @IBOutlet var chattingTableView: UITableView!
    @IBOutlet var textInputTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        navigationItem.title = friendName!
        chattingTableView.delegate = self
        chattingTableView.dataSource = self
        textInputTextView.layer.cornerRadius = 10
        textInputTextView.layer.borderWidth = 1
        textInputTextView.delegate = self
        currentUser = realm.object(ofType: UserAccount.self, forPrimaryKey: Auth.auth().currentUser!.uid)
        chattingTableView.register(UINib(nibName: "UserChatTableViewCell", bundle: nil), forCellReuseIdentifier: "userChatTableViewCell")
        chattingTableView.register(UINib(nibName: "ContactChatTableViewCell", bundle: nil), forCellReuseIdentifier: "contactChatTableViewCell")
        chattingTableView.separatorStyle = .none
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        chattingTableView.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func voiceButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func moreButtonPressed(_ sender: UIButton) {
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y = 0
        let keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        keyboardHeight = keyboardSize.height
        self.view.frame.origin.y -= keyboardHeight!
        view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y += keyboardHeight!
        view.layoutIfNeeded()
    }
    
    @objc func hideKeyboard() {
        textInputTextView.endEditing(true)
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
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = chattingTableView.dequeueReusableCell(withIdentifier: "contactChatTableViewCell", for: indexPath) as! ContactChatTableViewCell
            cell.contactImageView.image = UIImage(data: friendPhoto!)
            cell.contactChatContent.text = currentUser!.userChattingLogs[indexPath.row].content
            cell.selectionStyle = .none
            return cell
        }
    }
}



