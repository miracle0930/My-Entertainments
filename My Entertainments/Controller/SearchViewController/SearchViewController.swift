//
//  SearchViewController.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/1/22.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Firebase
import SVProgressHUD
import RealmSwift
import SDWebImage

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    var movies = [Movie]()
    var databaseRef: DatabaseReference!
    var storageRef: StorageReference!
    var movieImageCache = NSCache<NSString, NSData>()
    var sideMenuShowUp = false
    var currentUser: UserAccount?
    var tapGesture: UITapGestureRecognizer?
    var page = 1

    let realm = try! Realm()
    let userDefault = UserDefaults.standard
    var sideButtons = SideButtonGenerator.generateSideButtons()
    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var movieTableView: UITableView!
    @IBOutlet var sideMenuView: UIView!
    @IBOutlet var userInfoStackView: UIStackView!
    @IBOutlet var sideMenuButtonsTableView: UITableView!
    @IBOutlet var sideMenuLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var sideMenuTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var userInfoStackViewTrailing: NSLayoutConstraint!
    @IBOutlet var userPhotoImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userEmailLabel: UILabel!
    @IBOutlet var userIntroTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        navigationItem.title = "Search Movie"
        movieSearchBar.delegate = self
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        configureMovieTableView()
        currentUser = realm.object(ofType: UserAccount.self, forPrimaryKey: Auth.auth().currentUser!.uid)
        if currentUser == nil {
            initUserAccountFromFirebase(completion: {
                self.configureSideMenuView()
                self.configureTabItems()
                self.newFriendRequestReceived()
                self.requestHasBeenAccepted()
                self.newMsgReceivedFromNewContact()
                self.newMsgReceivedFromExistedContact()
                self.configureContactsArray()
            })
        } else {
            configureSideMenuView()
            configureTabItems()
            newFriendRequestReceived()
            requestHasBeenAccepted()
            newMsgReceivedFromNewContact()
            newMsgReceivedFromExistedContact()

        }
    }
    
    func emailFormatModifier(email: String) -> String {
        let modifiedEmail = email.replacingOccurrences(of: ".", with: "*")
        return modifiedEmail
    }
    
    
    // MARK: - SearchBar Implements
    @objc func tableViewTapped() {
        movieSearchBar.endEditing(true)
        hideSideMenu()
        sideMenuShowUp = false
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        hideSideMenu()
        sideMenuShowUp = false
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        SVProgressHUD.show()
        movies = [Movie]()
        page = 1
        loadMovies(page: page)
    }

    
    func loadMovies(page: Int) {
        var name = movieSearchBar.text!
        name = name.trimmingCharacters(in: NSCharacterSet.whitespaces)
        name = name.replacingOccurrences(of: " ", with: "%20")
        let url = "https://api.themoviedb.org/3/search/movie?api_key=236e7ef2c5b84703488c464d8d131d0c&language=en-US&query=\(name)&page=\(page)&include_adult=false"
        if name != "" {
            Alamofire.request(url, method: .get).responseJSON { (response) in
                if response.result.isSuccess {
                    let movieData: JSON = JSON(response.result.value!)
                    if page > movieData["total_pages"].intValue {
                        return
                    }
                    self.updateMovies(with: movieData)
                    self.page += 1
                } else {
                    SVProgressHUD.dismiss()
                    self.errorPop(errorMessage: "English supported only at this time :)")
                }
            }
        }
        movieSearchBar.endEditing(true)
    }
    

    func updateMovies(with jsonData: JSON) {
        if jsonData["total_results"] == 0 {
            errorPop(errorMessage: "Any typo?")
        } else {
            for (_, movieData) : (String, JSON) in jsonData["results"] {
                let movie = Movie()
                var movieName = movieData["title"].stringValue
                movieName = movieName.replacingOccurrences(of: ".", with: " ")
                movieName = movieName.replacingOccurrences(of: "#", with: " ")
                movieName = movieName.replacingOccurrences(of: "$", with: " ")
                movieName = movieName.replacingOccurrences(of: "[", with: "{")
                movieName = movieName.replacingOccurrences(of: "]", with: "}")
                movie.movieName = movieName
                movie.movieReleased = movieData["release_date"].stringValue
                movie.moviePosterUrl = "https://image.tmdb.org/t/p/w92\(movieData["poster_path"])"
                movie.movieId = movieData["id"].stringValue
                movies.append(movie)
            }
        }
        movieTableView.reloadData()
        SVProgressHUD.dismiss()

    }
    
    
    // MARK: - Movie and Database Interaction
    func errorPop(errorMessage: String) {
        let alert = UIAlertController(title: "No Result", message: errorMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - SideMenu Method
extension SearchViewController: SideMenuDelegate {

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
        sideMenuTrailingConstraint.constant = -UIScreen.main.bounds.width
        sideMenuLeadingConstraint.constant = -UIScreen.main.bounds.width
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showSideMenu() {
        self.sideMenuTrailingConstraint.constant = -UIScreen.main.bounds.width / 3
        self.sideMenuLeadingConstraint.constant = -UIScreen.main.bounds.width / 3
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
}

