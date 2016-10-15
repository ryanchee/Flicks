//
//  MovieInfo.swift
//  Flicks
//
//  Created by Ryan Chee on 10/13/16.
//  Copyright © 2016 ryanchee. All rights reserved.
//

import UIKit

class MovieInfo: NSObject {
    var poster_path: String? = nil
    var adult: Bool? = nil
    var overview: String? = nil
    var release_date: String? = nil
    var genre_ids: NSArray? = nil
    var id: Int? = nil
    var original_title: String? = nil
    var original_language: String? = nil
    var title: String? = nil
    var backdrop_path: String? = nil
    var popularity: Double? = nil
    var vote_count: Int? = nil
    var video: Bool? = nil
    var vote_average: Double? = nil
    
    init(movie: NSDictionary) {
        self.poster_path = movie.value(forKey: "poster_path") as? String
        self.adult = (movie.value(forKey: "adult") != nil)
        self.overview = movie.value(forKey: "overview") as? String
        self.release_date = movie.value(forKey: "release_date") as? String
        self.genre_ids = movie.value(forKey: "genre_ids") as? NSArray
        self.id = movie.value(forKey: "id") as? Int
        self.original_title = movie.value(forKey: "original_title") as? String
        self.original_language = movie.value(forKey: "original_language") as? String
        self.title = movie.value(forKey: "title") as? String
        self.backdrop_path = movie.value(forKey: "backdrop_path") as? String
        self.popularity = movie.value(forKey: "popularity") as? Double
        self.vote_count = movie.value(forKey: "vote_count") as? Int
        self.video = (movie.value(forKey: "video") != nil)
        self.vote_average = movie.value(forKey: "vote_average") as? Double
    }
}
