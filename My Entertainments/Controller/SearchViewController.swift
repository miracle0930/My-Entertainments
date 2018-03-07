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
//import FirebaseDatabase

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    var movies = [Movie]()
    var movieJsonDict = [String: JSON]()
    var ref: DatabaseReference!
    var movieImageCache = NSCache<NSString, NSData>()

    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var movieTableView: UITableView!
    let baseUrl = "http://www.omdbapi.com/?apikey=4d6fcc6c&s="
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Search Movie"
        setMovieTableViewSeperator()
        movieTableView.delegate = self
        movieTableView.dataSource = self
        movieSearchBar.delegate = self
        movieTableView.rowHeight = 100
        movieTableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieTableViewCell")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        ref = Database.database().reference()
    }
    
    // MARK: - SearchBar Implements
    @objc func tableViewTapped() {
        movieSearchBar.endEditing(true)
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
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
                    self.errorPop(errorMessage: "English supported only at this time :)")
                }
            }
        }
        searchBar.endEditing(true)
    }
    
    func updateMovies(with jsonData: JSON) {
        if jsonData["Response"] == "False" {
            errorPop(errorMessage: "Any typo?")
        } else {
            for (_, movieData) : (String, JSON) in jsonData["Search"] {
                print(movieData)
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
        cell.movieNameLabel.text = movies[indexPath.row].movieName
        cell.movieReleasedLabel.text = "Released: " + movies[indexPath.row].movieReleased!
        let path = self.movies[indexPath.row].movieImageUrl!
        downloadMovieCellImage(movieId: movies[indexPath.row].movieId!, movieCell: cell, imageUrl: path)
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
                let data = try? Data(contentsOf: url!)
                cell.movieImageView.image = UIImage(data: data!)
                movieImageCache.setObject(data! as NSData, forKey: id as NSString)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func setMovieTableViewSeperator() {
        if movies.count < 2 {
            movieTableView.separatorStyle = .none
        } else {
            movieTableView.separatorStyle = .singleLine
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "movieDetail", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! MovieDetailTableTableViewController
        if let indexPath = movieTableView.indexPathForSelectedRow {
            destination.movieId = movies[indexPath.row].movieId!
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        movieSearchBar.endEditing(true)
    }
    
}



