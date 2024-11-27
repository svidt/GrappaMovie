//
//  MovieListView.swift
//  GrappaMovie
//
//  Created by Kristian Emil on 27/11/2024.
//

import SwiftUI

struct MovieListView: View {
    // Access our view model through the environment
    @StateObject private var viewModel = MovieListViewModel()
    
    // Environment values for customization
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Main content list
            List {
                ForEach(viewModel.movies) { movie in
                    MovieRowView(movie: movie)
                        .onAppear {
                            // Load more content when reaching the end
                            Task {
                                await viewModel.loadMoreMoviesIfNeeded(currentMovie: movie)
                            }
                        }
                }
                
                // Loading indicator at bottom during pagination
                if viewModel.isLoading {
                    LoadingIndicatorView()
                }
            }
            .listStyle(.plain) // Modern inset grouped style
            .refreshable {     // Enable pull-to-refresh
                await viewModel.refresh()
            }
            
            // Search bar in navigation bar
            .searchable(text: $viewModel.searchText, prompt: "Search movies...")
            
            // Show loading view when first loading
            if viewModel.isLoading && viewModel.movies.isEmpty {
                LoadingView()
            }
            
            // Show error view if there's an error
            if let error = viewModel.error, viewModel.movies.isEmpty {
                ErrorView(message: error) {
                    Task {
                        await viewModel.refresh()
                    }
                }
            }
        }
        .task {
            // Load initial data when view appears
            await viewModel.loadInitialMovies()
        }
    }
}

// A reusable loading indicator view
struct LoadingIndicatorView: View {
    var body: some View {
        HStack {
            Spacer()
            ProgressView()
                .frame(height: 50)
            Spacer()
        }
    }
}

// A full-screen loading view
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading movies...")
                .foregroundColor(.secondary)
        }
    }
}

// A full-screen error view
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            Text("Something went wrong")
                .font(.headline)
            
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again") {
                retryAction()
            }
            .buttonStyle(.bordered)
        }
    }
}

// A view for each individual movie row
struct MovieRowView: View {
    let movie: Movie
    
    var body: some View {
        NavigationLink(destination: MovieDetailView(movie: movie)) {
            HStack(spacing: 16) {
                // Movie poster
                AsyncImage(url: movie.posterURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.2))
                }
                .frame(width: 80, height: 120)
                .cornerRadius(8)
                
                // Movie info
                VStack(alignment: .leading, spacing: 8) {
                    Text(movie.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text(movie.formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Rating
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", movie.voteAverage))
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                }
                .padding(.vertical, 8)
            }
        }
    }
}
