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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//extension ChattingViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        <#code#>
//    }
//
//
//}



