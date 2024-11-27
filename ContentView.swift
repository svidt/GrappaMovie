//
//  ContentView.swift
//  GrappaMovie
//
//  Created by Kristian Emil on 27/11/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MovieListViewModel()
    
    var body: some View {
        NavigationView {
            MovieListView()
                .navigationTitle("Movies")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


#Preview {
    ContentView()
}
