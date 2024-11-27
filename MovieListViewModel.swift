//
//  MovieListViewModel.swift
//  GrappaMovie
//
//  Created by Kristian Emil on 27/11/2024.
//

import Foundation
import SwiftUI
import Combine

// The ViewModel manages the state and business logic for our movie list
@MainActor
class MovieListViewModel: ObservableObject {
    
    // Published properties automatically notify SwiftUI views of changes
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    @Published var searchText = ""
    
    // State for pagination
    private var currentPage = 1
    private var canLoadMorePages = true
    
    // Tracks if we're showing search results or popular movies
    private var isSearching: Bool {
        !searchText.isEmpty
    }
    
    init() {
        // Set up search debouncing
        setupSearchDebouncing()
    }
    
    // Load initial data
    func loadInitialMovies() async {
        guard movies.isEmpty else { return }
        await loadMovies()
    }
    
    // Load more movies when reaching the end of the list
    func loadMoreMoviesIfNeeded(currentMovie movie: Movie) async {
        // If we're looking at the last few items, load more
        let thresholdIndex = movies.index(movies.endIndex, offsetBy: -3)
        if movies.firstIndex(where: { $0.id == movie.id }) ?? 0 >= thresholdIndex,
           !isLoading && canLoadMorePages {
            await loadMovies()
        }
    }
    
    // Main function to load movies, either from search or popular
    private func loadMovies() async {
        guard !isLoading && canLoadMorePages else { return }
        
        isLoading = true
        error = nil
        
        do {
            // Decide whether to fetch search results or popular movies
            let response = try await if isSearching {
                await MovieService.shared.searchMovies(query: searchText, page: currentPage)
            } else {
                await MovieService.shared.fetchPopularMovies(page: currentPage)
            }
            
            // Append new movies to existing list
            movies.append(contentsOf: response.results)
            currentPage += 1
            canLoadMorePages = currentPage <= response.totalPages
            
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // Refresh the movie list (e.g., when pulling to refresh)
    func refresh() async {
        currentPage = 1
        canLoadMorePages = true
        movies = []
        await loadMovies()
    }
    
    // Set up search functionality with debouncing
    private func setupSearchDebouncing() {
        // We use the searchText publisher to debounce search requests
        $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] newSearchText in
                guard let self = self else { return }
                
                Task {
                    await self.refresh()
                }
            }
            .store(in: &cancellables)
    }
    
    // Store our Combine cancellables
    private var cancellables = Set<AnyCancellable>()
}
