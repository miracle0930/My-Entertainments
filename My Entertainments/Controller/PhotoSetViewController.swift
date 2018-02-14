//
//  PhotoSetViewController.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/1/28.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import SDWebImage
import SVProgressHUD



class PhotoSetViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var userPhotoImageView: UIImageView!
    let imagePicker = UIImagePickerController()
    let storageRef = Storage.storage().reference()
    let databaseRef = Database.database().reference()
    let profileCahce = NSCache<NSString, NSData>()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "more"), style: .plain, target: self, action: #selector(changePhoto))
        configureUserPhoto()
    }
    
    
    
    func configureUserPhoto() {
        DispatchQueue.global().async {
            SVProgressHUD.show()
            let profileRef = self.storageRef.child("entertainments/\(Auth.auth().currentUser!.uid)/profile")
            profileRef.downloadURL { (url, error) in
                if error == nil {
                    
                    let placeholderImage = UIImage(named: "defaultphoto")
                    self.userPhotoImageView.sd_setImage(with: url, placeholderImage: placeholderImage)
                    
                } else {
                    print(error.debugDescription)
                }
            }
            SVProgressHUD.dismiss()
        }
    }
    
    
    @objc func changePhoto() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let openCameraAction = UIAlertAction(title: "Take Photo", style: .default) { (action) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let openGalleryAction = UIAlertAction(title: "Choose from Album", style: .default) { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(openCameraAction)
        alert.addAction(openGalleryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)

    }
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            userPhotoImageView.image = userPickedImage
            userPhotoImageView.reloadInputViews()
            let imageData = UIImageJPEGRepresentation(userPickedImage, 0.8)!
            let imagePath = "entertainments/\(Auth.auth().currentUser!.uid)/profile"
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            self.storageRef.child(imagePath).putData(imageData, metadata: metadata) { (metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                } else{
                    let downloadURL = metaData!.downloadURL()!.absoluteString
                    self.databaseRef.child("Users").child(Auth.auth().currentUser!.uid).child("Account").updateChildValues(["userPhoto": downloadURL])
                }
            }
            
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
