//
//  MovieService.swift
//  GrappaMovie
//
//  Created by Kristian Emil on 27/11/2024.
//

import Foundation

// MovieService handles all API communication with TMDB
actor MovieService {
    
    // Using actor ensures thread-safety for our shared instance
    static let shared = MovieService()
    
    // Your API key should ideally be in a configuration file or secure storage
    private let apiKey = "9d702fdc5b6e0206e3e9d491593621d3"
    private let baseURL = "https://api.themoviedb.org/3"
    
    // Custom error types for better error handling
    enum MovieError: Error {
        case invalidURL
        case invalidResponse
        case networkError(Error)
        case decodingError(Error)
    }
    
    // Fetch popular movies with pagination support
    func fetchPopularMovies(page: Int = 1) async throws -> MovieResponse {
        // Construct the URL with query parameters
        guard var urlComponents = URLComponents(string: "\(baseURL)/movie/popular") else {
            throw MovieError.invalidURL
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "page", value: String(page))
        ]
        
        guard let url = urlComponents.url else {
            throw MovieError.invalidURL
        }
        
        do {
            // Make the network request
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Verify we got a valid HTTP response
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw MovieError.invalidResponse
            }
            
            // Decode the JSON response into our MovieResponse model
            let decoder = JSONDecoder()
            return try decoder.decode(MovieResponse.self, from: data)
        } catch let decodingError as DecodingError {
            throw MovieError.decodingError(decodingError)
        } catch {
            throw MovieError.networkError(error)
        }
    }
    
    // Search for movies
    func searchMovies(query: String, page: Int = 1) async throws -> MovieResponse {
        guard var urlComponents = URLComponents(string: "\(baseURL)/search/movie") else {
            throw MovieError.invalidURL
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: String(page))
        ]
        
        guard let url = urlComponents.url else {
            throw MovieError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw MovieError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(MovieResponse.self, from: data)
        } catch let decodingError as DecodingError {
            throw MovieError.decodingError(decodingError)
        } catch {
            throw MovieError.networkError(error)
        }
    }
}
