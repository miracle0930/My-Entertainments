//
//  MovieDetailTableTableViewController.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/1/26.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MovieDetailTableTableViewController: UITableViewController {
    
    var movieId: String?
    @IBOutlet var movieImage: UIImageView!
    @IBOutlet var movieName: UILabel!
    @IBOutlet var movieReleased: UILabel!
    @IBOutlet var movieRating: UILabel!
    @IBOutlet var movieContent: UITextView!
    @IBOutlet var movieRuntime: UILabel!
    @IBOutlet var movieStatus: UILabel!
    var movieImageCache = NSCache<NSString, NSData>()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMovieInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    
    func loadMovieInfo() {
        
        let url = "https://api.themoviedb.org/3/movie/\(movieId!)?api_key=236e7ef2c5b84703488c464d8d131d0c&language=en-US"
        Alamofire.request(url, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let movieData: JSON = JSON(response.result.value!)
                self.movieName.text = movieData["title"].stringValue
                self.movieReleased.text = "Year: \(movieData["release_date"].stringValue)"
                self.movieRating.text = "Average Rating: \(movieData["vote_average"].stringValue)"
                self.movieRuntime.text = "Runtime: \(movieData["runtime"]) minutes"
                self.movieStatus.text = "Status: \(movieData["status"])"
                self.movieContent.text = movieData["overview"].stringValue
                let posterUrl = "https://image.tmdb.org/t/p/w154\(movieData["poster_path"])"
                self.getMovieImage(from: posterUrl)
                
            } else {
                print("error")
            }
        }
    }
    
    func getMovieImage(from path: String) {
        if path == "N/A" {
            movieImage.image = UIImage(named: "noimg")
        } else {
            if let cachedImage = movieImageCache.object(forKey: movieId! as NSString) as Data?{
                movieImage.image = UIImage(data: cachedImage)
            } else {
                let url = URL(string: path)
                if let data = try? Data(contentsOf: url!) {
                    movieImage.image = UIImage(data: data)
                    movieImageCache.setObject(data as NSData, forKey: movieId! as NSString)
                } else {
                    movieImage.image = UIImage(named: "noimg")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = super.tableView(tableView, cellForRowAt: indexPath)
//        if indexPath.section == 0 {
//            cell.fram
//        }
//    }
    


}
