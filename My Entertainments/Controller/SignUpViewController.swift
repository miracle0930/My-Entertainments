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
    @IBOutlet var middleView: UIView!
    @IBOutlet var upperView: UIView!
    
    var defaultUpperViewFrame: CGRect?
    var defaultMiddleViewFrame: CGRect?
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
        emailTextField.delegate = self
        
        defaultUpperViewFrame = upperView.frame
        defaultMiddleViewFrame = middleView.frame
    
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.5) {
            self.view.endEditing(true)
            self.upperView.frame = self.defaultUpperViewFrame!
            self.middleView.frame = self.defaultMiddleViewFrame!
            self.upperView.layoutIfNeeded()
            self.middleView.layoutIfNeeded()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            var upperViewFrame = self.upperView.frame
            var middleViewFrame = self.middleView.frame
            if middleViewFrame.origin.y < 0 {
                return
            }
            upperViewFrame.origin.y -= 150
            upperViewFrame.size.height += 150
            middleViewFrame.origin.y -= 150
            middleViewFrame.size.height += 150
            self.middleView.frame = middleViewFrame
            self.upperView.frame = upperViewFrame
            self.middleView.layoutIfNeeded()
            self.upperView.layoutIfNeeded()
        }
    }
    
    func passwordCheck() -> Bool {
        let password = passwordTextField.text!
        let retype = retypePasswordTextField.text!
        let alert = UIAlertController(title: "Sign up Failed", message: "", preferredStyle: .alert)
        if password == "" {
            alert.message = "Password can not be empty."
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
        if password != retype {
            alert.message = "Password doesn't match."
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
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
        let alert = UIAlertController(title: "Sign up Failed", message: "An initial photo must be selected.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        return -1
    }
    
    func writeToRealm(id: String, image: UIImage) {
        let imageData = UIImageJPEGRepresentation(image, 0.9)!
        do {
            try self.realm.write {
                let userAccount = UserAccount()
                userAccount.username = id
                userAccount.userPhoto = imageData
                self.realm.add(userAccount)
                print(userAccount)
            }
        } catch {
            print(error)
        }
    }
    
    func writeToStorage(id: String, image: UIImage) {
        let imageData = UIImageJPEGRepresentation(image, 0.9)!
        let imagePath = "entertainments/\(id)/profile"
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.child(imagePath).putData(imageData, metadata: metaData) { (metaData, error) in
            if error == nil {
                let downloadURL = metaData!.downloadURL()!.absoluteString
                self.databaseRef.child("Users").child(id).child("Account").updateChildValues(["userPhoto": downloadURL])
            } else {
                print(error!)
            }
        }
    }

    @IBAction func signUpOrGiveUp(_ sender: UIButton) {
        if sender.tag == 0 {
            SVProgressHUD.show()
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
                        "userIntro": ""
                    ]
                    self.userDefault.set(self.emailTextField.text!, forKey: "username")
                    self.userDefault.set(self.passwordTextField.text!, forKey: "password")
                    self.userDefault.set(true, forKey: "login")
                    self.databaseRef.child("Users").child(user!.uid).child("Account").setValue(userInfo)
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



