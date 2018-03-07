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
    @IBOutlet var upperView: UIView!
    
    let userDefault = UserDefaults.standard
    var defaultFrame: CGRect?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        defaultFrame = upperView.frame
        userPhotoImageView.layer.cornerRadius = 20
        userPhotoImageView.layer.borderColor = UIColor.black.cgColor
        userPhotoImageView.layer.borderWidth = 2
        userPhotoImageView.backgroundColor = UIColor.white
        userPhotoImageView.image = UIImage(named: "defaultphoto")
        emailTextField.delegate = self
        passwordTextField.delegate = self
        userDefaultConfigure()
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.5) {
            self.upperView.endEditing(true)
            self.upperView.frame = self.defaultFrame!
            self.upperView.layoutIfNeeded()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            var frame = self.upperView.frame
            if frame.origin.y < 0 {
                return
            }
            frame.origin.y -= 100
            frame.size.height += 100
            self.upperView.frame = frame
            self.upperView.layoutIfNeeded()
        }
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


