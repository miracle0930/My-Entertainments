//
//  SearchViewController+TableViewDelegate.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/25.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit
import Firebase

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
            if self.movieImageCache.object(forKey: id as NSString) as Data? == nil {
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
