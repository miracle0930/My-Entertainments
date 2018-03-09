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
import SVProgressHUD

class MovieDetailTableTableViewController: UITableViewController {
    
    var movieId: String?
    @IBOutlet var movieImage: UIImageView!
    @IBOutlet var movieName: UILabel!
    @IBOutlet var movieReleased: UILabel!
    @IBOutlet var movieRating: UILabel!
    @IBOutlet var movieContent: UITextView!
    @IBOutlet var movieRuntime: UILabel!
    @IBOutlet var movieStatus: UILabel!
    @IBOutlet var castCollectionView: UICollectionView!
    var movieImageCache = NSCache<NSString, NSData>()
    var castImageCache = NSCache<NSString, NSData>()
    var casts = [Cast]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
        loadMovieInfo()
        loadCastInfo()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        castCollectionView.collectionViewLayout = layout
        castCollectionView.delegate = self
        castCollectionView.dataSource = self
        castCollectionView.register(UINib(nibName: "MovieAndCastCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "castCollectionViewCell")
        tableView.backgroundColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func loadCastInfo() {
        let url = "https://api.themoviedb.org/3/movie/\(movieId!)/credits?api_key=236e7ef2c5b84703488c464d8d131d0c"
        Alamofire.request(url, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let rawCastData: JSON = JSON(response.result.value!)
                for (_, castData) : (String, JSON) in rawCastData["cast"] {
                    let cast = Cast()
                    cast.castName = castData["name"].stringValue
                    cast.castId = castData["id"].stringValue
                    cast.castImageUrl = "https://image.tmdb.org/t/p/w154\(castData["profile_path"].stringValue)"
                    self.casts.append(cast)
                    self.castCollectionView.reloadData()
                    SVProgressHUD.dismiss()
                }
            } else {
                print("error")
            }
        }
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
                let backdropUrl = "https://image.tmdb.org/t/p/w780\(movieData["backdrop_path"])"
                self.getMovieImage(posterUrl: posterUrl, backdropUrl: backdropUrl)
            } else {
                print("error")
            }
        }
    }
    
    func getMovieImage(posterUrl: String, backdropUrl: String) {
        
        if let cachedImage = movieImageCache.object(forKey: movieId! as NSString) as Data?{
            movieImage.image = UIImage(data: cachedImage)
        } else {
            let url = URL(string: posterUrl)
            if let data = try? Data(contentsOf: url!) {
                movieImage.image = UIImage(data: data)
                movieImageCache.setObject(data as NSData, forKey: movieId! as NSString)
            } else {
                movieImage.image = UIImage(named: "noimg")
            }
        }
        if let cachedImage = movieImageCache.object(forKey: "\(movieId!)/backdrop" as NSString) as Data? {
            tableView.backgroundView = UIImageView(image: UIImage(data: cachedImage))
            tableView.backgroundView!.contentMode = .scaleAspectFill
            
        } else {
            let url = URL(string: backdropUrl)
            if let data = try? Data(contentsOf: url!) {
                tableView.backgroundView = UIImageView(image: UIImage(data: data))
                tableView.backgroundView!.contentMode = .scaleAspectFill
                movieImageCache.setObject(data as NSData, forKey: "\(movieId!)/backdrop" as NSString)
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 100
        }
        return 20
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if indexPath.section == 0 || indexPath.section == 1{
            cell.layer.cornerRadius = 10
            cell.layer.borderWidth = 2
            cell.backgroundColor = UIColor(red: 40, green: 49, blue: 73, alpha: 1)
        }
        return cell
    }
}

extension MovieDetailTableTableViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return casts.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func setImageToCacheWithCompletionHandler(data: NSData, key: NSString, completion: () -> Void) {
        castImageCache.setObject(data as NSData, forKey: key)
        completion()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = castCollectionView.dequeueReusableCell(withReuseIdentifier: "castCollectionViewCell", for: indexPath) as! MovieAndCastCollectionViewCell
        cell.movieOrCastNameLabel.text = casts[indexPath.row].castName
        DispatchQueue.global().async {
            if self.castImageCache.object(forKey: self.casts[indexPath.row].castId! as NSString) as Data! == nil {
                let url = URL(string: self.casts[indexPath.row].castImageUrl!)
                if let data = try? Data(contentsOf: url!) {
                    self.setImageToCacheWithCompletionHandler(data: data as NSData, key: self.casts[indexPath.row].castId! as NSString, completion: {
                        DispatchQueue.main.sync {
                            self.castCollectionView.reloadData()
                        }
                    })
                }
            }
        }
        if let cachedImage = castImageCache.object(forKey: casts[indexPath.row].castId! as NSString) as Data? {
            cell.movieOrCastImageView.image = UIImage(data: cachedImage)
        } else {
            cell.movieOrCastImageView.image = UIImage(named: "noimg")
        }
        
//        if let cachedImage = castImageCache.object(forKey: casts[indexPath.row].castId! as NSString) as Data?{
//            cell.movieOrCastImageView.image = UIImage(data: cachedImage)
//        } else {
//            let url = URL(string: casts[indexPath.row].castImageUrl!)
//            if let data = try? Data(contentsOf: url!) {
//                cell.movieOrCastImageView.image = UIImage(data: data)
//                castImageCache.setObject(data as NSData, forKey: casts[indexPath.row].castId! as NSString)
//            } else {
//                cell.movieOrCastImageView.image = UIImage(named: "noimg")
//            }
//        }
        cell.movieOrCastImageView.layer.cornerRadius = 10
        cell.movieOrCastImageView.layer.borderWidth = 1
        cell.movieOrCastImageView.layer.masksToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 133, height: 240)
    }
    
    
}

