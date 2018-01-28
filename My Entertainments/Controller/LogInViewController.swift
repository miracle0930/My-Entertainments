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

class LogInViewController: UIViewController, SignUpProtocol {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
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
        
        SVProgressHUD.show()
        loginApp(username: emailTextField.text!, password: passwordTextField.text!)
        SVProgressHUD.dismiss()

    }
    
    func loginApp(username: String, password: String) {
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
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
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

