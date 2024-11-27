//
//  MovieDetailView.swift
//  GrappaMovie
//
//  Created by Kristian Emil on 27/11/2024.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @StateObject private var viewModel: MovieDetailViewModel
    
    init(movie: Movie) {
        self.movie = movie
        _viewModel = StateObject(wrappedValue: MovieDetailViewModel(movie: movie))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // The movie poster section displays the movie's image
                posterSection
                
                // Content section contains all the movie details
                VStack(alignment: .leading, spacing: 16) {
                    titleSection
                    dateSection
                    overviewSection
                    favoriteButton
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                shareButton
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
        .task {
            await viewModel.checkFavoriteStatus()
        }
    }
    
    // Movie poster at the top of the screen
    private var posterSection: some View {
        AsyncImage(url: movie.posterURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .foregroundColor(.gray.opacity(0.2))
                .overlay(
                    ProgressView()
                        .tint(.white)
                )
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .clipped()
    }
    
    // Title and rating section
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(movie.title)
                .font(.title)
                .fontWeight(.bold)
            
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text(String(format: "%.1f", movie.voteAverage))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // Release date section
    private var dateSection: some View {
        HStack {
            Image(systemName: "calendar")
                .foregroundColor(.secondary)
            Text("Released: \(movie.formattedDate)")
                .foregroundColor(.secondary)
        }
    }
    
    // Movie overview/description section
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Overview")
                .font(.headline)
            
            Text(movie.overview)
                .font(.body)
                .lineSpacing(4)
        }
    }
    
    // Favorite toggle button
    private var favoriteButton: some View {
        Button {
            Task {
                await viewModel.toggleFavorite()
            }
        } label: {
            HStack {
                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                Text(viewModel.isFavorite ? "Remove from Favorites" : "Add to Favorites")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(viewModel.isLoading)
    }
    
    // Share button in navigation bar
    private var shareButton: some View {
        Button {
            let activityVC = UIActivityViewController(
                activityItems: viewModel.shareMovie(),
                applicationActivities: nil
            )
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
    }
}
