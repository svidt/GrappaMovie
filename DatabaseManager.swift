//
//  DatabaseManager.swift
//  GrappaMovie
//
//  Created by Kristian Emil on 27/11/2024.
//

import Foundation
import GRDB

// This class will handle all our database operations
class DatabaseManager {
    // This gives us a single, shared instance we can use throughout the app
    static let shared = DatabaseManager()
    
    // This is our database connection
    private var dbQueue: DatabaseQueue!
    
    // This represents a favorite movie in our database
    struct FavoriteMovie: Codable, FetchableRecord, PersistableRecord {
        let id: Int
        let title: String
        let overview: String
        let posterPath: String?
        let releaseDate: String
        let voteAverage: Double
        
        // This tells GRDB how to create the database table
        static let databaseTableName = "favoriteMovie"
    }
    
    private init() {
        // Set up the database in the app's documents directory
        do {
            let databaseURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("movies.sqlite")
            
            dbQueue = try DatabaseQueue(path: databaseURL.path)
            
            // Create our table if it doesn't exist
            try dbQueue.write { db in
                try db.create(table: "favoriteMovie", ifNotExists: true) { table in
                    table.column("id", .integer).primaryKey()
                    table.column("title", .text)
                    table.column("overview", .text)
                    table.column("posterPath", .text)
                    table.column("releaseDate", .text)
                    table.column("voteAverage", .double)
                }
            }
        } catch {
            print("Database setup failed: \(error.localizedDescription)")
        }
    }
    
    // Add a movie to favorites
    func addFavorite(_ movie: Movie) throws {
        let favorite = FavoriteMovie(
            id: movie.id,
            title: movie.title,
            overview: movie.overview,
            posterPath: movie.posterPath,
            releaseDate: movie.releaseDate,
            voteAverage: movie.voteAverage
        )
        
        try dbQueue.write { db in
            try favorite.insert(db)
        }
    }
    
    // Remove a movie from favorites
    func removeFavorite(id: Int) throws {
        try dbQueue.write { db in
            _ = try FavoriteMovie.deleteOne(db, key: id)
        }
    }
    
    // Check if a movie is favorited
    func isFavorite(id: Int) throws -> Bool {
        try dbQueue.read { db in
            try FavoriteMovie.exists(db, key: id)
        }
    }
    
    // Get all favorite movies
    func getAllFavorites() throws -> [FavoriteMovie] {
        try dbQueue.read { db in
            try FavoriteMovie.fetchAll(db)
        }
    }
}
