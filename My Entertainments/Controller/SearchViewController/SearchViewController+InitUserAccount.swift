//
//  SearchViewController+InitUserAccount.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/22.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import Foundation
import Firebase
import RealmSwift
import SwiftyJSON

extension SearchViewController {
    
    func initUserAccountFromFirebase(completion: @escaping () -> Void) {
        let user = Auth.auth().currentUser!
        var imageData: Data?
        databaseRef.child("Users").child(self.emailFormatModifier(email: user.email!)).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = JSON(snapshot.value!)
            let imagePath = value["userPhoto"].stringValue
            let pathReference = Storage.storage().reference(forURL: imagePath)
            pathReference.downloadURL(completion: { (url, error) in
                if let _ = error {
                    return
                } else {
                    self.userPhotoImageView.sd_setImage(with: url, completed: { (image, _, _, _) in
                        imageData = UIImageJPEGRepresentation(image!, 1)!
                        do {
                            try self.realm.write {
                                let userAccount = UserAccount()
                                userAccount.userId = Auth.auth().currentUser!.uid
                                userAccount.userNickname = value["userNickname"].stringValue
                                userAccount.userEmail = value["userEmail"].stringValue
                                userAccount.userIntro = value["userIntro"].stringValue
                                userAccount.userPhoto = imageData!
                                self.realm.add(userAccount)
                                self.currentUser = self.realm.object(ofType: UserAccount.self, forPrimaryKey: Auth.auth().currentUser!.uid)
                                let systemContact = UserContact()
                                systemContact.contactName = "System"
                                systemContact.contactImage = UIImageJPEGRepresentation(UIImage(named: "settings")!, 1)!
                                userAccount.userContacts.append(systemContact)
                                completion()
                            }
                        } catch {
                            print(error)
                        }
                    })
                }
            })
        })
    }
}
