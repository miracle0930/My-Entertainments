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
    var baseUrl = "http://www.omdbapi.com/?apikey=4d6fcc6c&i="
    @IBOutlet var movieImage: UIImageView!
    @IBOutlet var movieName: UILabel!
    @IBOutlet var movieReleased: UILabel!
    @IBOutlet var movieGenre: UILabel!
    @IBOutlet var movieRating: UILabel!
    @IBOutlet var contentCell: UITableViewCell!
    @IBOutlet var movieContent: UITextView!
    var movieImageCache = NSCache<NSString, NSData>()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMovieInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    
    func loadMovieInfo() {
        let url = baseUrl + movieId!
        Alamofire.request(url, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let movieData: JSON = JSON(response.result.value!)
                self.movieName.text = movieData["Title"].stringValue
                self.movieReleased.text = "Year: " + movieData["Released"].stringValue + ",  Rated: " + movieData["Rated"].stringValue
                self.movieGenre.text = "Genre: " + movieData["Genre"].stringValue
                self.movieRating.text = "Rating: " + movieData["imdbRating"].stringValue
                self.movieContent.text = movieData["Plot"].stringValue
                self.getMovieImage(from: movieData["Poster"].stringValue)
                
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
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 2 {
            return 1
        } else {
            return 4
        }
    }


}
