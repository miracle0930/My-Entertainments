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

class SignUpViewController: UIViewController, UITextFieldDelegate {

    var delegate: SignUpProtocol?
    
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    var defaultframe: CGRect?
    let userDefault = UserDefaults.standard
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        defaultframe = view.frame
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.5) {
            self.view.endEditing(true)
            self.view.frame = self.defaultframe!
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            var frame = self.view.frame
            if frame.origin.y < 0 {
                return
            }
            frame.origin.y -= 216
            frame.size.height += 216
            self.view.frame = frame
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func signUpOrGiveUp(_ sender: UIButton) {
        if sender.tag == 0 {
            SVProgressHUD.show()
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: {
                (user, error) in
                SVProgressHUD.dismiss()
                if error == nil {
                    self.userDefault.set(self.emailTextField.text!, forKey: "username")
                    self.userDefault.set(self.passwordTextField.text!, forKey: "password")
                    self.userDefault.set(true, forKey: "login")
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
