//
//  CityListViewModel.swift
//  WeatherApp
//
//  Created by Ivan Khozeyev on 20.06.25.
//


import Foundation
import Combine // Import Combine for @Published and ObservableObject
import Network // For NWPathMonitor

// MARK: - CityListViewModel

/// Protocol for `CityListViewModel` to allow dependency injection and mock objects.
@MainActor
protocol CityListViewModelProtocol: ObservableObject {
    var citiesWeather: [CityWeather] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var isOffline: Bool { get }

    func fetchWeatherForAllCities()
    func updateSelectedCity(_ city: CityWeather)
}

/// ViewModel for the city list screen.
@MainActor // Ensures all published changes are on the main thread
class CityListViewModel: CityListViewModelProtocol {
    @Published var citiesWeather: [CityWeather] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isOffline: Bool = false

    private let weatherAPIClient: WeatherAPIClientProtocol
    private let persistenceService: WeatherPersistenceServiceProtocol
    private let networkMonitor: NWPathMonitor // For network reachability
    private var networkCancellable: AnyCancellable?
    private var predefinedCities: [String] = Constants.predefinedCities

    /// Initializes the view model.
    /// - Parameters:
    ///   - weatherAPIClient: The API client for fetching weather data.
    ///   - persistenceService: The service for saving/loading data locally.
    init(weatherAPIClient: WeatherAPIClientProtocol, persistenceService: WeatherPersistenceServiceProtocol) {
        self.weatherAPIClient = weatherAPIClient
        self.persistenceService = persistenceService
        self.networkMonitor = NWPathMonitor()
        setupNetworkMonitoring()
        
        // Initial load from persistence
        loadCachedData()
    }

    /// Sets up network reachability monitoring.
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            // Run on MainActor to update @Published properties
            Task { @MainActor in
                let wasOffline = self.isOffline
                self.isOffline = (path.status == .unsatisfied) // True if no internet
                
                // If just came online, refresh data
                if wasOffline && !self.isOffline {
                    self.fetchWeatherForAllCities()
                }
                
                if self.isOffline {
                    self.errorMessage = NetworkError.noInternetConnection.localizedDescription
                } else if self.errorMessage == NetworkError.noInternetConnection.localizedDescription {
                    // Clear message if it was about offline mode and now online
                    self.errorMessage = nil
                }
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor.start(queue: queue)
    }

    /// Loads cached weather data from persistence.
    private func loadCachedData() {
        do {
            self.citiesWeather = try persistenceService.fetchAllSavedWeathers()
        } catch {
            self.errorMessage = "שגיאה בטעינת נתונים שמורים: \(error.localizedDescription)" // Error loading saved data
            print("Error loading cached data: \(error)")
        }
    }

    /// Fetches current weather data for all predefined cities.
    func fetchWeatherForAllCities() {
        guard !isLoading else { return } // Prevent multiple simultaneous fetches

        isLoading = true
        errorMessage = nil

        Task {
            do {
                if self.isOffline {
                    throw NetworkError.noInternetConnection // Explicitly throw if offline
                }
                
                let responses = try await weatherAPIClient.fetchCurrentWeather(forCities: predefinedCities)
                let newCityWeathers = responses.map { CityWeather(response: $0) }
                
                // Update UI and save to persistence
                self.citiesWeather = newCityWeathers
                try persistenceService.saveWeathers(cityWeathers: newCityWeathers)
                
            } catch let networkError as NetworkError {
                self.errorMessage = networkError.localizedDescription
                if case .noInternetConnection = networkError {
                    // Already showing cached data, just update message
                } else {
                    // For other network errors, clear data if no cache
                    if self.citiesWeather.isEmpty {
                         self.citiesWeather = [] // Clear if no cached data
                    }
                }
            } catch {
                self.errorMessage = "אירעה שגיאה בלתי צפויה: \(error.localizedDescription)" // An unexpected error occurred
                print("Unexpected error fetching weather: \(error)")
            }
            isLoading = false
        }
    }
    
    // This function is for future use if we need to select a city to pass to detail.
    // For now, CityDetailViewModel will fetch its own data based on city name.
    func updateSelectedCity(_ city: CityWeather) {
        // No-op for now, as navigation is handled by coordinator.
        // If MVVM required selection, this would be updated.
    }

    deinit {
        networkMonitor.cancel() // Stop monitoring when view model is deallocated
    }
}
