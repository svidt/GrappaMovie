//
//  Movie.swift
//  GrappaMovie
//
//  Created by Kristian Emil on 27/11/2024.
//

import Foundation

// The Movie struct represents a single movie from TMDB API
// We make it Identifiable so we can use it in SwiftUI Lists
// We make it Codable so we can decode it from JSON
struct Movie: Identifiable, Codable {
    
    // Custom coding keys to match TMDB's JSON structure
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case genreIds = "genre_ids"
    }
    
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String
    let voteAverage: Double
    let genreIds: [Int]
    
    // Computed property to generate full poster URL
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    // Computed property to format the release date
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: releaseDate) else { return "N/A" }
        
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
}

// This struct represents the response we get from TMDB API
struct MovieResponse: Codable {
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
