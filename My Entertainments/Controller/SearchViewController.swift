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
import FirebaseDatabase

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    var movies = [Movie]()
    var movieSet = Set<String>()
    var ref: DatabaseReference!

    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var movieTableView: UITableView!
    let baseUrl = "http://www.omdbapi.com/?apikey=4d6fcc6c&t="
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        navigationItem.title = "Search Movie"
        setMovieTableViewSeperator()
        movieTableView.delegate = self
        movieTableView.dataSource = self
        movieSearchBar.delegate = self
        movieTableView.rowHeight = 199.5
        movieTableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieTableViewCell")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        movieTableView.addGestureRecognizer(tapGesture)

    }
    
    @objc func tableViewTapped() {
        movieSearchBar.endEditing(true)
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var name = searchBar.text!
        name = name.trimmingCharacters(in: NSCharacterSet.whitespaces)
        name = name.replacingOccurrences(of: " ", with: "%20")
        let url = baseUrl + name
        Alamofire.request(url, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let movieData: JSON = JSON(response.result.value!)
                self.updateMovies(with: movieData)
            } else {
                self.errorPop(errorMessage: "English supported only at this time :)")
            }
        }
    }
    
    func updateMovies(with jsonData: JSON) {
        if jsonData["Response"] == "False" {
            errorPop(errorMessage: "Any typo?")
        } else {
            let movie = Movie()
            movie.movieName = jsonData["Title"].stringValue
            movie.movieReleased = jsonData["Released"].stringValue
            movie.movieGenre = jsonData["Genre"].stringValue
            movie.movieRated = jsonData["Rated"].stringValue
            movie.movieRating = jsonData["imdbRating"].stringValue
            movie.movieImageUrl = jsonData["Poster"].stringValue
            if !movieSet.contains(movie.movieName!) {
                addMovieToDatabase(movie: movie)
                movieSet.insert(movie.movieName!)
                movies.insert(movie, at: 0)
                setMovieTableViewSeperator()
                movieTableView.reloadData()
            }
        }
    }
    
    func addMovieToDatabase(movie: Movie) {
        let movieInfo = [
            "released": movie.movieReleased!,
            "rated": movie.movieRated!,
            "imageURL": movie.movieImageUrl!,
            "rating": movie.movieRating!,
            "genre": movie.movieGenre!
        ]
        self.ref.child("Users").child(Auth.auth().currentUser!.uid).child("Movies").child(movie.movieName!).setValue(movieInfo)
    }
    
    func errorPop(errorMessage: String) {
        let alert = UIAlertController(title: "No Result", message: errorMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath) as! MovieTableViewCell
        cell.movieNameLabel.text = movies[indexPath.row].movieName
        cell.movieReleasedLabel.text = "Released: " + movies[indexPath.row].movieReleased!
        cell.movieGenreLabel.text = "Genre: " + movies[indexPath.row].movieGenre!
        cell.movieRatedLabel.text = "Rated: " + movies[indexPath.row].movieRated!
        cell.movieRatingLabel.text = "IMDB Rating: " + movies[indexPath.row].movieRating!
        let path = movies[indexPath.row].movieImageUrl!
        let url = URL(string: path)
        let data = try? Data(contentsOf: url!)
        if data == nil {
            cell.movieImageView.image = UIImage(named: "noimg")
        } else {
            cell.movieImageView.image = UIImage(data: data!)
        }
        return cell
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
    
}



