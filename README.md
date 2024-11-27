# GrappaMovie iOS App

A feature-rich iOS application for browsing and managing your favorite movies, built using SwiftUI and following Apple's Human Interface Guidelines (HIG). This app demonstrates modern iOS development practices, clean architecture, and fundamental programming principles.

## Features

- Browse popular movies with infinite scrolling
- Search for movies with debounced input
- View detailed movie information
- Save favorite movies locally
- Share movie details
- Pull-to-refresh functionality
- Elegant error handling and loading states

## Architecture

The app follows the MVVM (Model-View-ViewModel) architectural pattern, ensuring clean separation of concerns and maintainable code. Here's how the components are organized:

### Models
- `Movie`: Represents movie data from TMDB API
- `MovieResponse`: Handles API response pagination
- `DatabaseManager.FavoriteMovie`: Local database model for saved favorites

### Views
- `ContentView`: Main app container
- `MovieListView`: Displays movie list with search
- `MovieDetailView`: Shows detailed movie information
- `MovieRowView`: Individual movie cell in the list

### ViewModels
- `MovieListViewModel`: Manages movie list state and pagination
- `MovieDetailViewModel`: Handles movie details and favorites

### Services
- `MovieService`: Manages API communication with TMDB
- `DatabaseManager`: Handles local data persistence

## Technical Implementation

### API Integration
The app interfaces with The Movie Database (TMDB) API to fetch movie data. The `MovieService` class handles all network communication using modern Swift concurrency (async/await).

```swift
// Example API call
let movies = try await MovieService.shared.fetchPopularMovies(page: 1)
```

### Local Storage
GRDB (SQLite wrapper) is used for local storage of favorite movies, providing efficient data persistence and querying capabilities.

```swift
// Example database operation
try DatabaseManager.shared.addFavorite(movie)
```

### UI/UX Design
The app follows Apple's Human Interface Guidelines with:
- Consistent navigation patterns
- Clear visual hierarchy
- Responsive feedback
- Smooth animations
- Appropriate loading states

### Performance Optimizations
- Debounced search to minimize API calls
- Efficient image loading with AsyncImage
- Pagination for large datasets
- Actor-based concurrency for thread safety

## Programming Principles Applied

### 1. DRY (Don't Repeat Yourself)
- Reusable views like `LoadingIndicatorView`
- Shared networking logic in `MovieService`
- Common database operations in `DatabaseManager`

### 2. KISS (Keep It Simple, Stupid)
- Clear, focused view structures
- Straightforward data flow
- Minimal state management
- Intuitive user interactions

### 3. Single Responsibility Principle
Each component has a single, well-defined purpose:
- Views handle only UI rendering
- ViewModels manage state and business logic
- Service classes handle specific tasks (networking, database)

## Error Handling

The app implements comprehensive error handling:
- Custom `MovieError` types for specific failure cases
- User-friendly error messages
- Graceful fallbacks
- Retry mechanisms

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+
- GRDB Swift Package

## Dependencies

- GRDB: SQLite database management
- TMDB API Key (required for movie data)

## Setup Instructions

1. Clone the repository
2. Open `GrappaMovie.xcodeproj` in Xcode
3. Add your TMDB API key in `MovieService.swift`
4. Build and run

## Code Style

The project follows Swift standard coding conventions:
- Clear naming conventions
- Comprehensive documentation comments
- Organized file structure
- Consistent formatting

## Future Improvements

Potential areas for enhancement:
- Offline support
- Advanced filtering options
- User reviews and ratings
- Personalized recommendations
- Movie trailers integration

## Testing

While not currently implemented, the MVVM architecture makes the app highly testable:
- ViewModels can be tested in isolation
- Service layers can be mocked
- Database operations can be tested with in-memory storage

## Contributing

Feel free to submit issues and enhancement requests.

## License

This project is intended for educational purposes as part of a Computer Science course.

## Acknowledgments

- TMDB for providing the movie database API
- GRDB for the SQLite wrapper
- Apple's SwiftUI framework and Human Interface Guidelines
