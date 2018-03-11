//
//  PeopleTableViewController.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/9.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SVProgressHUD

class PeopleTableViewController: UITableViewController {
    
    var personId: String?
    var currentUser: UserAccount?
    @IBOutlet var personName: UILabel!
    @IBOutlet var personImageView: UIImageView!
    @IBOutlet var birthdayLabel: UILabel!
    @IBOutlet var personBirthPlaceLabel: UILabel!
    @IBOutlet var personBiography: UITextView!
    @IBOutlet var moviesTableViewCell: UITableViewCell!
    @IBOutlet var moviesCollectionView: UICollectionView!
    var movieImageCache = NSCache<NSString, NSData>()
    var profileImageCache = NSCache<NSString, NSData>()
    var relatedMovies = [RelatedMovie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        personBiography.layer.cornerRadius = 10
        personBiography.layer.borderWidth = 1
        moviesCollectionView.delegate = self
        moviesCollectionView.dataSource = self
        moviesCollectionView.register(UINib(nibName: "PeopleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "peopleCollectionViewCell")
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        moviesCollectionView.collectionViewLayout = layout
        loadPersonInfo()
        loadRelatedMovieInfo()
    }
    
    func loadRelatedMovieInfo() {
        let url = "https://api.themoviedb.org/3/person/\(personId!)/movie_credits?api_key=236e7ef2c5b84703488c464d8d131d0c&language=en-US"
        Alamofire.request(url, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let relatedMovieData: JSON = JSON(response.result.value!)
                if relatedMovieData["cast"].count == 0 {
                    self.moviesTableViewCell.backgroundView = UIImageView(image: UIImage(named: "notAvailable"))
                    self.moviesTableViewCell.backgroundView!.contentMode = .scaleAspectFit
                    self.moviesTableViewCell.contentView.backgroundColor = UIColor.clear
                    self.moviesTableViewCell.contentView.subviews.first?.backgroundColor = UIColor.clear
                    return
                }
                for (_, movieData) : (String, JSON) in relatedMovieData["cast"] {
                    let relatedMovie = RelatedMovie()
                    relatedMovie.characterName = movieData["character"].stringValue
                    relatedMovie.movieId = movieData["id"].stringValue
                    relatedMovie.movieImageUrl = "https://image.tmdb.org/t/p/w154\(movieData["poster_path"].stringValue)"
                    relatedMovie.movieName = movieData["title"].stringValue
                    self.relatedMovies.append(relatedMovie)
                }
                self.moviesCollectionView.reloadData()
                self.moviesCollectionView.collectionViewLayout.invalidateLayout()
            } else {
                print("error")
            }
        }
    }
    
    
    func loadPersonInfo() {
        let url = "https://api.themoviedb.org/3/person/\(personId!)?api_key=236e7ef2c5b84703488c464d8d131d0c&language=en-US"
        Alamofire.request(url, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let personData: JSON = JSON(response.result.value!)
                self.personName.text = personData["name"].stringValue
                self.personBiography.text = personData["biography"].stringValue
                self.personBirthPlaceLabel.text = personData["place_of_birth"].stringValue
                let birthday = personData["birthday"].stringValue
                let rawDeathday = personData["deathday"].string
                if let deathDay = rawDeathday {
                    self.birthdayLabel.text = "\(birthday) ~ \(deathDay)"
                } else {
                    self.birthdayLabel.text = "\(birthday) ~ \("Now")"
                }
                self.getPersonImage(url: "https://image.tmdb.org/t/p/w154\(personData["profile_path"].stringValue)")
            }
        }
    }
    
    func getPersonImage(url: String) {
        DispatchQueue.global().async {
            if self.profileImageCache.object(forKey: self.personId! as NSString) as Data! == nil {
                let url = URL(string: url)
                if let data = try? Data(contentsOf: url!) {
                    self.setImageToCacheWithCompletionHandler(cache: self.profileImageCache, key: self.personId! as NSString, data: data as NSData, completion: {
                        DispatchQueue.main.sync {
                            if let cachedImage = self.profileImageCache.object(forKey: self.personId! as NSString) as Data? {
                                self.personImageView.image = UIImage(data: cachedImage)
                            } else {
                                self.personImageView.image = UIImage(named: "noimg")
                            }
                        }
                    })
                }
            }
        }
    }
    
    func setImageToCacheWithCompletionHandler(cache: NSCache<NSString, NSData>, key: NSString, data: NSData, completion: () -> Void) {
        cache.setObject(data, forKey: key)
        completion()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

}

extension PeopleTableViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return relatedMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = moviesCollectionView.dequeueReusableCell(withReuseIdentifier: "peopleCollectionViewCell", for: indexPath) as! PeopleCollectionViewCell
        cell.characterLabel.text = "\(relatedMovies[indexPath.row].characterName!)"
        cell.movieNameLabel.text = relatedMovies[indexPath.row].movieName!
        DispatchQueue.global().async {
            if self.movieImageCache.object(forKey: self.relatedMovies[indexPath.row].movieId! as NSString) as Data! == nil {
                let url = URL(string: self.relatedMovies[indexPath.row].movieImageUrl!)
                if let data = try? Data(contentsOf: url!) {
                    self.setImageToCacheWithCompletionHandler(cache: self.movieImageCache, key: self.relatedMovies[indexPath.row].movieId! as NSString, data: data as NSData, completion: {
                        DispatchQueue.main.sync {
                            self.moviesCollectionView.reloadData()
                        }
                    })
                }
            }
        }
        if let cachedImage = movieImageCache.object(forKey: relatedMovies[indexPath.row].movieId! as NSString) as Data? {
            cell.peopleImageView.image = UIImage(data: cachedImage)
        } else {
            cell.peopleImageView.image = UIImage(named: "noimg")
        }
        cell.peopleImageView.layer.cornerRadius = 10
        cell.peopleImageView.layer.borderWidth = 1
        cell.peopleImageView.layer.masksToBounds = true
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 2
        cell.backgroundColor = UIColor(red: 40, green: 49, blue: 73, alpha: 1)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 133, height: 274)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "fromPeopleToMovie", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromPeopleToMovie" {
            let destination = segue.destination as! MovieDetailTableViewController
            if let indexPath = moviesCollectionView.indexPathsForSelectedItems!.first {
                destination.movieId = relatedMovies[indexPath.row].movieId!
                destination.currentUser = currentUser!
            }
        }
    }
    

    
}
