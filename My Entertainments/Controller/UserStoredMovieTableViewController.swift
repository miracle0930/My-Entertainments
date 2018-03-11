//
//  LikedMovieTableViewController.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/10.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class UserStoredMovieTableViewController: UITableViewController {
    
    let realm = try! Realm()
    var currentUser: UserAccount?
    var userStoredMovies: Results<UserStoredMovie>?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = realm.object(ofType: UserAccount.self, forPrimaryKey: Auth.auth().currentUser!.uid)
        userStoredMovies = currentUser!.userStoredMovies.sorted(byKeyPath: "movieName")
        tableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "userStoredMovieTableviewCell")
        tableView.rowHeight = 100
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return userStoredMovies!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userStoredMovieTableviewCell", for: indexPath) as! MovieTableViewCell
        cell.movieNameLabel.text = userStoredMovies![indexPath.section].movieName
        cell.movieReleasedLabel.text = userStoredMovies![indexPath.section].movieReleased
        cell.movieImageView.image = UIImage(data: userStoredMovies![indexPath.section].moviePoster)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "fromStoredToMovie", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromStoredToMovie" {
            let destinationVC = segue.destination as! MovieDetailTableViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.movieId = userStoredMovies![indexPath.section].movieId
                destinationVC.currentUser = currentUser!
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
}
