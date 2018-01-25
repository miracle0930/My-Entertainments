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
import CoreData

class LogInViewController: UIViewController, SignUpProtocol {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            if result.count != 0 {
                let currentUser = result.first as! NSManagedObject
                let login = currentUser.value(forKey: "login") as! Bool
                let username = currentUser.value(forKey: "username") as! String
                let password = currentUser.value(forKey: "password") as! String
                if login {
                    self.loginApp(username: username, password: password)
                }
            }
        } catch {
            print("error")
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
        Auth.auth().signIn(withEmail: username, password:password) { (user, error) in
            if error == nil {
                self.performSegue(withIdentifier: "oldLogIn", sender: self)
            } else {
                let alert = UIAlertController(title: "Log in Failed", message: "Please check your username or password.", preferredStyle: .alert)
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

