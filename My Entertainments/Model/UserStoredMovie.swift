//
//  UserStoredMovie.swift
//  My Entertainments
//
//  Created by 管 皓 on 2018/3/10.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import Foundation
import RealmSwift

class UserStoredMovie: Object {
    
    @objc dynamic var movieId = ""
    @objc dynamic var movieName = ""
    @objc dynamic var movieReleased = ""
    @objc dynamic var movieRating = ""
    @objc dynamic var movieRunTime = ""
    @objc dynamic var movieStatus = ""
    @objc dynamic var movieTagline = ""
    @objc dynamic var movieGenre = ""
    @objc dynamic var movieContent = ""
    @objc dynamic var moviePoster = Data()
    @objc dynamic var movieBackdrop = Data()
    var storedMoviesDataHolder = LinkingObjects(fromType: UserAccount.self, property: "userStoredMovies")
    
   
    
}
