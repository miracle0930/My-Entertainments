//
//  SignUpViewController.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/1/21.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import RealmSwift


class SignUpViewController: UIViewController, UITextFieldDelegate {

    var delegate: SignUpProtocol?
    let realm = try! Realm()
    
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet var userDefaultPhotosCollectionView: UICollectionView!

    

    let userDefault = UserDefaults.standard
    let defaultPhotos = [UIImage(named: "boy1"), UIImage(named: "girl1"), UIImage(named: "boy2"), UIImage(named: "girl2"),
                         UIImage(named: "boy3"), UIImage(named: "girl3"), UIImage(named: "boy4"), UIImage(named: "girl4"),
                         UIImage(named: "boy5"), UIImage(named: "girl5"), UIImage(named: "boy6"), UIImage(named: "girl6"),
                         UIImage(named: "boy7"), UIImage(named: "girl7"), UIImage(named: "boy8"), UIImage(named: "girl8")]
    var photosSelected = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
    var databaseRef: DatabaseReference!
    var storageRef: StorageReference!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        userDefaultPhotosCollectionView.collectionViewLayout = layout
        userDefaultPhotosCollectionView.delegate = self
        userDefaultPhotosCollectionView.dataSource = self
        userDefaultPhotosCollectionView.register(UINib(nibName: "UserDefaultPhotosCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "userDefaultPhotoCell")

        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= 100
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y += 100
        }
    }
    
    func passwordCheck() -> Bool {
        let password = passwordTextField.text!
        let retype = retypePasswordTextField.text!
        if password == "" {
            signUpFailed(msg: "Password can not be empty :)")
            return false
        } else if password != retype {
            signUpFailed(msg: "Password doesn't match :)")
            return false
        }
        return true
    }
    
    func defaultPhotoCheck() -> Int {
        for i in stride(from: 0, to: defaultPhotos.count, by: 1) {
            if photosSelected[i] {
                return i
            }
        }
        signUpFailed(msg: "An initial photo must be selected :)")
        return -1
    }
    
    func nicknameCheck() -> Bool {
        if nicknameTextField.text! == "" {
            signUpFailed(msg: "Pick a nickname for you :)")
            return false
        }
        return true
    }
    
    
    func signUpFailed(msg: String) {
        let alert = UIAlertController(title: "Sign up Failed", message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    func writeToRealm(id: String, image: UIImage) {
        let imageData = UIImageJPEGRepresentation(image, 1)!
        do {
            try self.realm.write {
                let userAccount = UserAccount()
                userAccount.userId = id
                userAccount.userNickname = self.nicknameTextField.text!
                userAccount.userIntro = "I love movies!"
                userAccount.userEmail = self.emailTextField.text!
                userAccount.userPhoto = imageData
                let systemContact = UserContact()
                systemContact.contactNickname = "System"
                systemContact.contactImage = UIImageJPEGRepresentation(UIImage(named: "settings")!, 1)!
                userAccount.userContacts.append(systemContact)
                self.realm.add(userAccount)
            }
        } catch {
            print(error)
        }
    }
    
    func writeToStorage(id: String, image: UIImage) {
        let imageData = UIImageJPEGRepresentation(image, 1)!
        let imagePath = "entertainments/\(id)/profile"
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.child(imagePath).putData(imageData, metadata: metaData) { (metaData, error) in
            if error == nil {
                let downloadURL = metaData!.downloadURL()!.absoluteString
                self.databaseRef.child("Users").child(self.emailFormatModifier(email: self.emailTextField.text!)).updateChildValues(["userPhoto": downloadURL])
            } else {
                print(error!)
            }
        }
    }

    @IBAction func signUpOrGiveUp(_ sender: UIButton) {
        if sender.tag == 0 {
            SVProgressHUD.show()
            if !nicknameCheck() {
                SVProgressHUD.dismiss()
                return
            }
            if !passwordCheck() {
                SVProgressHUD.dismiss()
                return
            }
            let selectPhotoIndex = defaultPhotoCheck()
            if selectPhotoIndex == -1 {
                SVProgressHUD.dismiss()
                return
            }
            let userPhoto = defaultPhotos[selectPhotoIndex]!
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: {
                (user, error) in
                SVProgressHUD.dismiss()
                if error == nil {
                    let userInfo = [
                        "userNickname": self.nicknameTextField.text!,
                        "userIntro": "I love movies!",
                        "userEmail": self.emailTextField.text!
                    ]
                    let friendRequestInfo = [
                        "from": [],
                        "to": [],
                    ] as [String : Any]
                    self.userDefault.set(self.emailTextField.text!, forKey: "username")
                    self.userDefault.set(self.passwordTextField.text!, forKey: "password")
                    self.userDefault.set(user!.uid, forKey: "userId")
                    self.userDefault.set(true, forKey: "login")
                    self.databaseRef.child("Users").child(self.emailFormatModifier(email: self.emailTextField.text!)).setValue(userInfo)
                    self.databaseRef.child("NewFriendRequest").child(self.emailFormatModifier(email: self.emailTextField.text!)).setValue(friendRequestInfo)
                    self.writeToRealm(id: user!.uid, image: userPhoto)
                    self.writeToStorage(id: user!.uid, image: userPhoto)
                    self.performSegue(withIdentifier: "newLogIn", sender: self)
                } else {
                    let alert = UIAlertController(title: "Sign up Failed", message: error?.localizedDescription, preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func emailFormatModifier(email: String) -> String {
        let modifiedEmail = email.replacingOccurrences(of: ".", with: "*")
        return modifiedEmail
    }
    
    
}

extension SignUpViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 16
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = userDefaultPhotosCollectionView.dequeueReusableCell(withReuseIdentifier: "userDefaultPhotoCell", for: indexPath) as! UserDefaultPhotosCollectionViewCell
        cell.userDefaultPhoto.image = defaultPhotos[indexPath.row]
        cell.userDefaultPhoto.backgroundColor = photosSelected[indexPath.row] ? UIColor.white : UIColor.clear
        cell.layer.cornerRadius = 20
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if photosSelected[indexPath.row] {
            photosSelected[indexPath.row] = false
        } else {
            photosSelected = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
            photosSelected[indexPath.row] = true
        }
        userDefaultPhotosCollectionView.reloadData()
    }
    
    
}



