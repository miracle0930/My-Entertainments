//
//  UserStoredMovieViewController.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/12.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import SwiftyJSON

class UserStoredMovieViewController: UIViewController {

    let realm = try! Realm()
    var currentUser: UserAccount?
    var userStoredMovies: Results<UserStoredMovie>?
    var sideButtons = SideButtonGenerator.generateSideButtons()
    var sideMenuShowUp = false
    @IBOutlet var sideMenuView: UIView!
    @IBOutlet var sideButtonsTableView: UITableView!
    @IBOutlet var userStoredMovieTableView: UITableView!
    @IBOutlet var userInfoStackView: UIStackView!
    @IBOutlet var userPhotoImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userIntroTextView: UITextView!
    @IBOutlet var sideMenuLeading: NSLayoutConstraint!
    @IBOutlet var sideMenuTrailing: NSLayoutConstraint!
    @IBOutlet var userInfoTrailing: NSLayoutConstraint!
    var tapGesture: UITapGestureRecognizer?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "My Movies"
        currentUser = realm.object(ofType: UserAccount.self, forPrimaryKey: Auth.auth().currentUser!.uid)
        userStoredMovies = currentUser!.userStoredMovies.sorted(byKeyPath: "movieName")
        configureSideMenuTableView()
        configureMovieTableView()
    }
    
    func configureSideMenuTableView() {
        let screenWidth = UIScreen.main.bounds.width
        sideMenuTrailing.constant = -screenWidth
        sideMenuLeading.constant = -screenWidth
        userInfoTrailing.constant = (2 * screenWidth / 3 - userPhotoImageView.frame.width) / 3
        userPhotoImageView.layer.cornerRadius = 10
        userPhotoImageView.layer.borderWidth = 1
        userPhotoImageView.layer.masksToBounds = true
        sideMenuView.layer.cornerRadius = 10
        sideMenuView.layer.borderWidth = 2
        sideMenuView.layer.masksToBounds = true
        sideMenuView.backgroundColor = UIColor(patternImage: UIImage(named: "sideMenuBackground")!)
        sideButtonsTableView.delegate = self
        sideButtonsTableView.dataSource = self
        sideButtonsTableView.separatorStyle = .none
        sideButtonsTableView.register(UINib(nibName: "SideMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "sideMenuButtonCell")
        userPhotoImageView.image = UIImage(data: currentUser!.userPhoto)
        userNameLabel.text = currentUser!.userNickname
        userIntroTextView.text = currentUser!.userIntro
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        userStoredMovieTableView.reloadData()
    }
    
    func configureMovieTableView() {
        userStoredMovieTableView.delegate = self
        userStoredMovieTableView.dataSource = self
        userStoredMovieTableView.rowHeight = 100
        userStoredMovieTableView.separatorStyle = .none
        userStoredMovieTableView.backgroundView = UIImageView(image: UIImage(named: "movieBackground"))
        userStoredMovieTableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "userStoredMovieTableViewCell")
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        tapGesture!.cancelsTouchesInView = false
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeGestureDetected))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeGestureDetected))
        swipeRight.direction = .right
        userStoredMovieTableView.addGestureRecognizer(tapGesture!)
        userStoredMovieTableView.addGestureRecognizer(swipeLeft)
        userStoredMovieTableView.addGestureRecognizer(swipeRight)
    }
    
    @objc func swipeGestureDetected(gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            hideSideMenu()
            sideMenuShowUp = false
            break
        case .right:
            showSideMenu()
            sideMenuShowUp = true
            break
        default:
            return
        }
    }
    
    @IBAction func callSideMenu(_ sender: UIBarButtonItem) {
        if sideMenuShowUp {
            hideSideMenu()
        } else {
            showSideMenu()
        }
        sideMenuShowUp = !sideMenuShowUp
    }
    
    func hideSideMenu() {
        sideMenuTrailing.constant = -UIScreen.main.bounds.width
        sideMenuLeading.constant = -UIScreen.main.bounds.width
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showSideMenu() {
        self.sideMenuTrailing.constant = -UIScreen.main.bounds.width / 3
        self.sideMenuLeading.constant = -UIScreen.main.bounds.width / 3
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - SearchBar Implements
    @objc func tableViewTapped() {
        hideSideMenu()
        sideMenuShowUp = false
    }
    

}

extension UserStoredMovieViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == userStoredMovieTableView {
            return userStoredMovies!.count
        } else {
            return sideButtons.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == userStoredMovieTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userStoredMovieTableViewCell", for: indexPath) as! MovieTableViewCell
            cell.layer.cornerRadius = 10
            cell.layer.borderWidth = 1
            cell.selectionStyle = .none
            cell.backgroundView = UIImageView(image: UIImage(named: "cellBackground"))
            cell.layer.masksToBounds = true
            cell.movieNameLabel.text = userStoredMovies![indexPath.section].movieName
            cell.movieReleasedLabel.text = userStoredMovies![indexPath.section].movieReleased
            cell.movieImageView.image = UIImage(data: userStoredMovies![indexPath.section].moviePoster)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sideMenuButtonCell", for: indexPath) as! SideMenuTableViewCell
            cell.sideButtonImage.image = sideButtons[indexPath.section].sideButtonImage
            cell.sideButtonLabel.text = sideButtons[indexPath.section].sideButtonLabel
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "fromStoredToMovie", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromStoredToMovie" {
            let destinationVC = segue.destination as! MovieDetailTableViewController
            if let indexPath = userStoredMovieTableView.indexPathForSelectedRow {
                destinationVC.movieId = userStoredMovies![indexPath.section].movieId
                destinationVC.currentUser = currentUser!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == userStoredMovieTableView {
            return 5
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == userStoredMovieTableView {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: userStoredMovieTableView.bounds.size.width, height: 5))
            headerView.backgroundColor = UIColor.clear
            return headerView
        } else {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: sideMenuView.bounds.size.width, height: 10))
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
}
