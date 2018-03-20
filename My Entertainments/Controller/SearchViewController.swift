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
        currentUser = realm.object(ofType: UserAccount.self, forPrimaryKey: Auth.auth().currentUser!.uid)
        movieSearchBar.delegate = self
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        configureMovieTableView()
        configureSideMenuView()
        newFriendRequestReceived()
    }
    
    func configureSideMenuView() {
        let screenWidth = UIScreen.main.bounds.width
        sideMenuView.layer.cornerRadius = 10
        sideMenuView.layer.borderWidth = 2
        sideMenuView.layer.masksToBounds = true
        sideMenuView.backgroundColor = UIColor(patternImage: UIImage(named: "sideMenuBackground")!)
        sideMenuTrailingConstraint.constant = -screenWidth
        sideMenuLeadingConstraint.constant = -screenWidth
        userInfoStackViewTrailing.constant = (2 * screenWidth / 3 - userPhotoImageView.frame.width) / 3
        userPhotoImageView.layer.cornerRadius = 10
        userPhotoImageView.layer.borderWidth = 1
        userPhotoImageView.layer.masksToBounds = true
        sideMenuButtonsTableView.delegate = self
        sideMenuButtonsTableView.dataSource = self
        sideMenuButtonsTableView.separatorStyle = .none
        sideMenuButtonsTableView.register(UINib(nibName: "SideMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "sideMenuButtonCell")
        if let user = currentUser {
            userPhotoImageView.image = UIImage(data: user.userPhoto)
            userNameLabel.text = user.userNickname
            userIntroTextView.text = user.userIntro
            userEmailLabel.text = user.userEmail
        } else {
            // When a new app installed, no data stored in local Realm, so we need to download data from firebase and store into Realm
            let user = Auth.auth().currentUser!
            var imageData: Data?
            databaseRef.child("Users").child(self.emailFormatModifier(email: user.email!)).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = JSON(snapshot.value!)
                self.userNameLabel.text = value["userNickname"].stringValue
                self.userEmailLabel.text = value["userEmail"].stringValue
                self.userIntroTextView.text = value["userIntro"].stringValue
                let imagePath = value["userPhoto"].stringValue
                let pathReference = Storage.storage().reference(forURL: imagePath)
                pathReference.downloadURL(completion: { (url, error) in
                    if let _ = error {
                        return
                    } else {
                        self.userPhotoImageView.sd_setImage(with: url, completed: { (image, _, _, _) in
                            imageData = UIImageJPEGRepresentation(image!, 1)!
                            do {
                                try self.realm.write {
                                    let userAccount = UserAccount()
                                    userAccount.userId = Auth.auth().currentUser!.uid
                                    userAccount.userNickname = self.userNameLabel.text!
                                    userAccount.userEmail = self.userEmailLabel.text!
                                    userAccount.userIntro = self.userIntroTextView.text
                                    userAccount.userPhoto = imageData!
                                    self.realm.add(userAccount)
                                    self.currentUser = self.realm.object(ofType: UserAccount.self, forPrimaryKey: Auth.auth().currentUser!.uid)
                                }
                            } catch {
                                print(error)
                            }
                        })
                    }
                })
            })
        }
        self.view.layoutIfNeeded()
    }
    
    func emailFormatModifier(email: String) -> String {
        let modifiedEmail = email.replacingOccurrences(of: ".", with: "*")
        return modifiedEmail
    }
    
    func configureMovieTableView() {
        movieTableView.delegate = self
        movieTableView.dataSource = self
        movieTableView.rowHeight = 100
        movieTableView.backgroundView = UIImageView(image: UIImage(named: "movieBackground"))
        movieTableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieTableViewCell")
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        tapGesture!.cancelsTouchesInView = false
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeGestureDetected))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeGestureDetected))
        swipeRight.direction = .right
        movieTableView.addGestureRecognizer(tapGesture!)
        movieTableView.addGestureRecognizer(swipeLeft)
        movieTableView.addGestureRecognizer(swipeRight)
    }
    
    // MARK: - SearchBar Implements
    @objc func tableViewTapped() {
        movieSearchBar.endEditing(true)
        hideSideMenu()
        sideMenuShowUp = false

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
extension SearchViewController {
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
        tapGesture!.cancelsTouchesInView = false
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showSideMenu() {
        self.sideMenuTrailingConstraint.constant = -UIScreen.main.bounds.width / 3
        self.sideMenuLeadingConstraint.constant = -UIScreen.main.bounds.width / 3
        tapGesture!.cancelsTouchesInView = true
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - TableView Delegate and Datasource Implements
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == movieTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath) as! MovieTableViewCell
            cell.layer.cornerRadius = 10
            cell.layer.borderWidth = 1
            cell.selectionStyle = .none
            cell.backgroundView = UIImageView(image: UIImage(named: "cellBackground"))
            cell.layer.masksToBounds = true
            cell.movieNameLabel.text = movies[indexPath.section].movieName
            cell.movieReleasedLabel.text = "Released: " + movies[indexPath.row].movieReleased!
            let path = self.movies[indexPath.section].moviePosterUrl!
            downloadMovieCellImage(movieId: movies[indexPath.section].movieId!, movieCell: cell, imageUrl: path)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sideMenuButtonCell", for: indexPath) as! SideMenuTableViewCell
            cell.sideButtonImage.image = sideButtons[indexPath.section].sideButtonImage
            cell.sideButtonLabel.text = sideButtons[indexPath.section].sideButtonLabel
            cell.selectionStyle = .none
            return cell
        }
        
    }
    
    func setImageToCacheWithCompletionHandler(data: NSData, key: NSString, completion: () -> Void) {
        movieImageCache.setObject(data, forKey: key)
        completion()
    }
    
    func downloadMovieCellImage(movieId id: String, movieCell cell: MovieTableViewCell, imageUrl path: String) {
        
        DispatchQueue.global().async {
            if self.movieImageCache.object(forKey: id as NSString) as Data! == nil {
                let url = URL(string: path)
                if let data = try? Data(contentsOf: url!) {
                    self.setImageToCacheWithCompletionHandler(data: data as NSData, key: id as NSString, completion: {
                        DispatchQueue.main.sync {
                            self.movieTableView.reloadData()
                        }
                    })
                }
            }
        }
        
        if let cachedImage = movieImageCache.object(forKey: id as NSString) as Data? {
            cell.movieImageView.image = UIImage(data: cachedImage)
        } else {
            cell.movieImageView.image = UIImage(named: "noimg")
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == movieTableView {
            return 5
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == movieTableView {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: movieTableView.bounds.size.width, height: 5))
            headerView.backgroundColor = UIColor.clear
            return headerView
        } else {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: sideMenuView.bounds.size.width, height: 10))
            return headerView
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == movieTableView {
            return movies.count
        } else {
            return sideButtons.count
        }
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == movieTableView {
            performSegue(withIdentifier: "movieDetail", sender: self)
        } else {
            if indexPath.section == 1 {
                do {
                    try Auth.auth().signOut()
                    userDefault.set(false, forKey: "login")
                    performSegue(withIdentifier: "userlogout", sender: self)
                } catch {
                    print("error")
                }
            }
            print("select on sidemenu tableview")
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "movieDetail" {
            let destination = segue.destination as! MovieDetailTableViewController
            if let indexPath = movieTableView.indexPathForSelectedRow {
                destination.movieId = movies[indexPath.section].movieId!
                destination.currentUser = currentUser!
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        movieSearchBar.endEditing(true)
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            loadMovies(page: page)
        }
    }
    
}



