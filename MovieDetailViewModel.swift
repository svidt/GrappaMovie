//
//  MovieDetailViewModel.swift
//  GrappaMovie
//
//  Created by Kristian Emil on 27/11/2024.
//

import SwiftUI
import GRDB

class MovieDetailViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published var error: Error? // Changed from String? to Error? for proper error handling
    @Published var isFavorite = false
    
    private let movie: Movie
    
    init(movie: Movie) {
        self.movie = movie
        checkFavoriteStatus()
    }
    
    // Added this function that was missing
    func clearError() {
        error = nil
    }
    
    func checkFavoriteStatus() {
        do {
            isFavorite = try DatabaseManager.shared.isFavorite(id: movie.id)
        } catch {
            self.error = error
        }
    }
    
    func toggleFavorite() {
        isLoading = true
        
        do {
            if isFavorite {
                try DatabaseManager.shared.removeFavorite(id: movie.id)
            } else {
                try DatabaseManager.shared.addFavorite(movie)
            }
            isFavorite.toggle()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    // Added this function that was missing
    func shareMovie() -> [String] {
        ["""
        Check out this movie!
        
        \(movie.title)
        Released: \(movie.formattedDate)
        Rating: \(String(format: "%.1f", movie.voteAverage))/10
        
        \(movie.overview)
        """]
    }
}
