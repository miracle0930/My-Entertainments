//
//  ViewController.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/1/21.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import RealmSwift

class LogInViewController: UIViewController, SignUpProtocol, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet var userPhotoImageView: UIImageView!
    let userDefault = UserDefaults.standard
    let realm = try! Realm()
    var currentUser: UserAccount?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        userPhotoImageView.layer.cornerRadius = 10
        userPhotoImageView.layer.masksToBounds = true
        userPhotoImageView.layer.borderWidth = 1
        userPhotoImageView.layer.backgroundColor = UIColor.white.cgColor
        userDefaultConfigure()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func userDefaultConfigure() {
        let login = userDefault.bool(forKey: "login")
        if login {
            let username = userDefault.string(forKey: "username")!
            let password = userDefault.string(forKey: "password")!
            loginApp(username: username, password: password)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = true
        if let id = userDefault.string(forKey: "userId") {
            currentUser = realm.object(ofType: UserAccount.self, forPrimaryKey: id)
            if let user = currentUser {
                userPhotoImageView.image = UIImage(data: user.userPhoto)
            }
        } else {
            userPhotoImageView.image = UIImage(named: "defaultphoto")
        }
    }
    
    

    @IBAction func logInPressed(_ sender: UIButton) {
        
        loginApp(username: emailTextField.text!, password: passwordTextField.text!)

    }
    
    func loginApp(username: String, password: String) {
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: username, password: password) { (user, error) in
            if error == nil {
                self.userDefault.set(username, forKey: "username")
                self.userDefault.set(password, forKey: "password")
                self.userDefault.set(user!.uid, forKey: "userId")
                self.userDefault.set(true, forKey: "login")
                self.performSegue(withIdentifier: "oldLogIn", sender: self)
            } else {
                let alert = UIAlertController(title: error.debugDescription, message: "Please check your username or password.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
        SVProgressHUD.dismiss()
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "newUserSignUp", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newUserSignUp" {
            let pass = segue.destination as! SignUpViewController
            pass.delegate = self
        }
    }
    
}


