//
//  SearchViewController+ConfigureView.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/22.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import SwiftyJSON


extension SearchViewController {
    
    func configureSideMenuView() {
        let screenWidth = UIScreen.main.bounds.width
        sideMenuView.layer.cornerRadius = 10
        sideMenuView.layer.borderWidth = 2
        sideMenuView.layer.masksToBounds = true
        sideMenuView.backgroundColor = UIColor(patternImage: UIImage(named: "sideMenuBackground")!)
        sideMenuTrailingConstraint.constant = -screenWidth
        sideMenuLeadingConstraint.constant = -screenWidth
        userInfoStackViewTrailing.constant = (2 * screenWidth / 3 - userPhotoImageView.frame.width) / 3
        userPhotoImageView.layer.cornerRadius = 10
        userPhotoImageView.layer.borderWidth = 1
        userPhotoImageView.layer.masksToBounds = true
        sideMenuButtonsTableView.delegate = self
        sideMenuButtonsTableView.dataSource = self
        sideMenuButtonsTableView.separatorStyle = .none
        sideMenuButtonsTableView.register(UINib(nibName: "SideMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "sideMenuButtonCell")
        userPhotoImageView.image = UIImage(data: currentUser!.userPhoto)
        userNameLabel.text = currentUser!.userNickname
        userIntroTextView.text = currentUser!.userIntro
        userEmailLabel.text = currentUser!.userEmail
        sideMenuButtonsTableView.reloadData()
    }
    
    func configureTabItems() {
        tabBarController?.tabBar.items![3].badgeValue = String(currentUser!.userSystemRequests.count)
        if tabBarController?.tabBar.items![3].badgeValue == "0" {
            tabBarController?.tabBar.items![3].badgeValue = nil
        }
    }
    
    func configureMovieTableView() {
        movieTableView.delegate = self
        movieTableView.dataSource = self
        movieTableView.rowHeight = 100
        movieTableView.backgroundView = UIImageView(image: UIImage(named: "movieBackground"))
        movieTableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieTableViewCell")
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        tapGesture!.cancelsTouchesInView = false
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeGestureDetected))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeGestureDetected))
        swipeRight.direction = .right
        movieTableView.addGestureRecognizer(tapGesture!)
        movieTableView.addGestureRecognizer(swipeLeft)
        movieTableView.addGestureRecognizer(swipeRight)
    }
    
    func configureContactsArray() {
        databaseRef.child("Contacts").observeSingleEvent(of: .value) { (snapshot) in
            let value = JSON(snapshot.value!)
            for (_, friend) : (String, JSON) in value[self.emailFormatModifier(email: self.currentUser!.userEmail)] {
                self.databaseRef.child("Users").child(self.emailFormatModifier(email: friend.stringValue)).observeSingleEvent(of: .value, with: { (rawFriendInfo) in
                    let friendInfo = JSON(rawFriendInfo.value!)
                    let contact = UserContact()
                    contact.contactEmail = friendInfo["userEmail"].stringValue
                    contact.contactNickname = friendInfo["userNickname"].stringValue
                    if let imageData = try? Data(contentsOf: URL(string: friendInfo["userPhoto"].stringValue)!) {
                        contact.contactImage = imageData
                    }
                    do {
                        try self.realm.write {
                            self.currentUser!.userContacts.append(contact)
                        }
                    } catch {
                        print(error)
                    }
                })
            }
        }
    }
}
