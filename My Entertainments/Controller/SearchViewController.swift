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

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    var movies = [Movie]()
    var ref: DatabaseReference!
    var movieImageCache = NSCache<NSString, NSData>()
    var sideMenuShowUp = false
    var currentUser: UserAccount?
    var tapGesture: UITapGestureRecognizer?


    let baseUrl = "http://www.omdbapi.com/?apikey=4d6fcc6c&s="
    let realm = try! Realm()
    let userDefault = UserDefaults.standard
    
    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var movieTableView: UITableView!
    
    @IBOutlet var sideMenuView: UIView!
    @IBOutlet var sideMenuLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var sideMenuTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var userPhotoImageView: UIImageView!
    @IBOutlet var userPhotoTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var userButtonView: UIStackView!
    @IBOutlet var userInfoTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var userInfoView: UIStackView!
    @IBOutlet var userButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userIntroTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        navigationItem.title = "Search Movie"
        currentUser = realm.object(ofType: UserAccount.self, forPrimaryKey: Auth.auth().currentUser!.uid)
        movieSearchBar.delegate = self
        ref = Database.database().reference()
        configureMovieTableView()
        configureSideMenuView()
        
    }
    
    func configureSideMenuView() {
        let screenWidth = UIScreen.main.bounds.width
        sideMenuTrailingConstraint.constant = -screenWidth
        sideMenuLeadingConstraint.constant = -screenWidth
        userPhotoTrailingConstraint.constant = (screenWidth / 2 - userPhotoImageView.frame.width) / 2
        userInfoTrailingConstraint.constant = (screenWidth / 2 - userInfoView.frame.width) / 2
        userButtonTrailingConstraint.constant = (screenWidth / 2 - userButtonView.frame.width) / 2
        userPhotoImageView.image = UIImage(data: currentUser!.userPhoto)
        userPhotoImageView.layer.cornerRadius = 10
        userPhotoImageView.layer.borderWidth = 1
        userPhotoImageView.layer.masksToBounds = true
        userNameLabel.text = currentUser!.userNickname
        userIntroTextView.text = currentUser!.userIntro
        self.view.layoutIfNeeded()
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
        view.addGestureRecognizer(tapGesture!)
        view.addGestureRecognizer(swipeLeft)
        view.addGestureRecognizer(swipeRight)

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
        sideMenuTrailingConstraint.constant = -UIScreen.main.bounds.width
        sideMenuLeadingConstraint.constant = -UIScreen.main.bounds.width
        tapGesture!.cancelsTouchesInView = false
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showSideMenu() {
        self.sideMenuTrailingConstraint.constant = -UIScreen.main.bounds.width / 2
        self.sideMenuLeadingConstraint.constant = -UIScreen.main.bounds.width / 2
        tapGesture!.cancelsTouchesInView = true
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    @IBAction func sideMenuButtonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            break
        case 1:
            movies = [Movie]()
            movieTableView.reloadData()
            break
        case 2:
            do {
                try Auth.auth().signOut()
                userDefault.set(false, forKey: "login")
                performSegue(withIdentifier: "userlogout", sender: self)
            } catch {
                print("error")
            }
            break
        default:
            return
        }
    }
    
    
    // MARK: - SearchBar Implements
    @objc func tableViewTapped() {
        movieSearchBar.endEditing(true)
        hideSideMenu()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        SVProgressHUD.show()
        var name = searchBar.text!
        name = name.trimmingCharacters(in: NSCharacterSet.whitespaces)
        name = name.replacingOccurrences(of: " ", with: "%20")
        let url = baseUrl + name
        if name != "" {
            Alamofire.request(url, method: .get).responseJSON { (response) in
                if response.result.isSuccess {
                    let movieData: JSON = JSON(response.result.value!)
                    self.updateMovies(with: movieData)
                } else {
                    SVProgressHUD.dismiss()
                    self.errorPop(errorMessage: "English supported only at this time :)")
                }
            }
        }
        searchBar.endEditing(true)
    }

    func updateMovies(with jsonData: JSON) {
        movies = [Movie]()
        if jsonData["Response"] == "False" {
            errorPop(errorMessage: "Any typo?")
        } else {
            for (_, movieData) : (String, JSON) in jsonData["Search"] {
                let movie = Movie()
                var movieName = movieData["Title"].stringValue
                movieName = movieName.replacingOccurrences(of: ".", with: " ")
                movieName = movieName.replacingOccurrences(of: "#", with: " ")
                movieName = movieName.replacingOccurrences(of: "$", with: " ")
                movieName = movieName.replacingOccurrences(of: "[", with: "{")
                movieName = movieName.replacingOccurrences(of: "]", with: "}")
                movie.movieName = movieName
                movie.movieReleased = movieData["Year"].stringValue
                movie.movieImageUrl = movieData["Poster"].stringValue
                movie.movieId = movieData["imdbID"].stringValue
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

// MARK: - TableView Delegate and Datasource Implements
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath) as! MovieTableViewCell
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 1
        cell.selectionStyle = .none
        cell.backgroundView = UIImageView(image: UIImage(named: "cellBackground"))
        cell.layer.masksToBounds = true
        cell.movieNameLabel.text = movies[indexPath.section].movieName
        cell.movieReleasedLabel.text = "Released: " + movies[indexPath.row].movieReleased!
        let path = self.movies[indexPath.section].movieImageUrl!
        downloadMovieCellImage(movieId: movies[indexPath.section].movieId!, movieCell: cell, imageUrl: path)
        return cell
    }
    
    func downloadMovieCellImage(movieId id: String, movieCell cell: MovieTableViewCell, imageUrl path: String) {
        if path == "N/A" {
            cell.movieImageView.image = UIImage(named: "noimg")
        } else {
            if let cachedImage = movieImageCache.object(forKey: id as NSString) as Data?{
                cell.movieImageView.image = UIImage(data: cachedImage)
            } else {
                let url = URL(string: path)
                if let data = try? Data(contentsOf: url!) {
                    cell.movieImageView.image = UIImage(data: data)
                    movieImageCache.setObject(data as NSData, forKey: id as NSString)
                } else {
                    cell.movieImageView.image = UIImage(named: "noimg")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: movieTableView.bounds.size.width, height: 5))
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "movieDetail", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "movieDetail" {
            let destination = segue.destination as! MovieDetailTableTableViewController
            if let indexPath = movieTableView.indexPathForSelectedRow {
                destination.movieId = movies[indexPath.section].movieId!
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        movieSearchBar.endEditing(true)
    }
    
}



