//
//  CityDetailViewModel.swift
//  WeatherApp
//
//  Created by Ivan Khozeyev on 20.06.25.
//

import Foundation
import Combine
import Network

// MARK: - CityDetailViewModel

/// Protocol for `CityDetailViewModel`.
@MainActor
protocol CityDetailViewModelProtocol: ObservableObject {
    var cityWeather: CityWeather? { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var isOffline: Bool { get }
    
    var cityName: String { get } // City name to fetch details for

    func fetchWeatherDetails()
    func getWeatherIconURL() -> URL?
}

/// ViewModel for the city detail screen.
@MainActor // Ensures all published changes are on the main thread
class CityDetailViewModel: CityDetailViewModelProtocol {
    @Published var cityWeather: CityWeather?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isOffline: Bool = false

    let cityName: String // The city for which to display details

    private let weatherAPIClient: WeatherAPIClientProtocol
    private let persistenceService: WeatherPersistenceServiceProtocol
    private let networkMonitor: NWPathMonitor
    private var networkCancellable: AnyCancellable?
    
    /// Initializes the view model with city name.
    init(cityName: String, weatherAPIClient: WeatherAPIClientProtocol, persistenceService: WeatherPersistenceServiceProtocol) {
        self.cityName = cityName
        self.weatherAPIClient = weatherAPIClient
        self.persistenceService = persistenceService
        self.networkMonitor = NWPathMonitor()
        setupNetworkMonitoring()
        
        // Initial load for the specific city
        loadCachedDataForCity()
    }

    /// Sets up network reachability monitoring.
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            Task { @MainActor in
                let wasOffline = self.isOffline
                self.isOffline = (path.status == .unsatisfied)
                
                // If just came online, refresh data for this city
                if wasOffline && !self.isOffline {
                    self.fetchWeatherDetails()
                }
                
                if self.isOffline {
                    self.errorMessage = NetworkError.noInternetConnection.localizedDescription
                } else if self.errorMessage == NetworkError.noInternetConnection.localizedDescription {
                    self.errorMessage = nil
                }
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitorDetail")
        networkMonitor.start(queue: queue)
    }

    /// Loads cached weather data for the specific city.
    private func loadCachedDataForCity() {
        do {
            let allCachedWeathers = try persistenceService.fetchAllSavedWeathers()
            self.cityWeather = allCachedWeathers.first(where: { $0.name == cityName })
        } catch {
            self.errorMessage = "שגיאה בטעינת נתונים שמורים לעיר: \(error.localizedDescription)" // Error loading saved data for city
            print("Error loading cached data for city \(cityName): \(error)")
        }
    }

    /// Fetches weather details for the specified city.
    func fetchWeatherDetails() {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                if self.isOffline {
                    throw NetworkError.noInternetConnection
                }
                
                let response = try await weatherAPIClient.fetchCurrentWeather(forCity: cityName)
                let newCityWeather = CityWeather(response: response)
                self.cityWeather = newCityWeather
                try persistenceService.saveWeather(cityWeather: newCityWeather) // Save/update specific city data
                
            } catch let networkError as NetworkError {
                self.errorMessage = networkError.localizedDescription
            } catch {
                self.errorMessage = "אירעה שגיאה בלתי צפויה: \(error.localizedDescription)"
                print("Unexpected error fetching weather details: \(error)")
            }
            isLoading = false
        }
    }

    /// Returns the URL for the weather icon.
    /// - Returns: An optional `URL`.
    func getWeatherIconURL() -> URL? {
        guard let iconCode = cityWeather?.weatherIcon else { return nil }
        return weatherAPIClient.getWeatherIconURL(iconCode: iconCode)
    }

    deinit {
        networkMonitor.cancel()
    }
}

