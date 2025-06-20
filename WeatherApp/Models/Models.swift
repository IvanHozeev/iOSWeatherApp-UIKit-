//
//  Models.swift
//  WeatherApp
//
//  Created by Ivan Khozeyev on 20.06.25.
//


// MARK: - Models.swift

import Foundation
import CoreData // Import CoreData for NSManagedObjectContext

// MARK: - Data Models for Weather API Response

/// Decodable struct representing the main weather information.
struct MainWeather: Decodable {
    let temp: Double
    let feelsLike: Double?
    let tempMin: Double
    let tempMax: Double
    let pressure: Int?
    let humidity: Int

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
    }
}

/// Decodable struct representing weather condition details.
struct WeatherCondition: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

/// Decodable struct representing wind information.
struct Wind: Decodable {
    let speed: Double
    let deg: Int?
}

/// Decodable struct representing cloudiness.
struct Clouds: Decodable {
    let all: Int
}

/// Decodable struct representing system parameters (sunrise, sunset).
struct Sys: Decodable {
    let type: Int?
    let id: Int?
    let country: String?
    let sunrise: Int?
    let sunset: Int?
}

/// The main decodable struct for OpenWeatherMap current weather API response.
struct OpenWeatherResponse: Decodable {
    let coord: [String: Double]?
    let weather: [WeatherCondition]
    let base: String?
    let main: MainWeather
    let visibility: Int?
    let wind: Wind?
    let clouds: Clouds?
    let dt: Int?
    let sys: Sys?
    let timezone: Int?
    let id: Int
    let name: String
    let cod: Int? // Response code
}

// MARK: - App-Specific Data Model (for UI and CoreData)

/// A simple struct to represent city weather data in the UI.
/// This acts as a bridge between the API response and CoreData entity, and the UI.
struct CityWeather: Identifiable, Hashable {
    let id: Int // City ID from OpenWeatherMap
    let name: String
    let temperature: Double
    let tempMin: Double
    let tempMax: Double
    let humidity: Int
    let windSpeed: Double
    let weatherIcon: String // Icon code, e.g., "04n"
    let weatherDescription: String // e.g., "overcast clouds"
    let lastUpdated: Date // When this data was last fetched

    /// Initializes from an OpenWeatherResponse.
    init(response: OpenWeatherResponse) {
        self.id = response.id
        self.name = response.name
        self.temperature = response.main.temp
        self.tempMin = response.main.tempMin
        self.tempMax = response.main.tempMax
        self.humidity = response.main.humidity
        self.windSpeed = response.wind?.speed ?? 0.0 // Default to 0 if no wind data
        self.weatherIcon = response.weather.first?.icon ?? "" // Take first icon
        self.weatherDescription = response.weather.first?.description ?? "" // Take first description
        self.lastUpdated = Date() // Set current date as last updated
    }

    /// Initializes from a CoreData `CityWeatherEntity`.
    init(entity: CityWeatherEntity) {
        self.id = Int(entity.id)
        self.name = entity.name ?? "Unknown"
        self.temperature = entity.temperature
        self.tempMin = entity.tempMin
        self.tempMax = entity.tempMax
        self.humidity = Int(entity.humidity)
        self.windSpeed = entity.windSpeed
        self.weatherIcon = entity.weatherIcon ?? ""
        self.weatherDescription = entity.weatherDescription ?? ""
        self.lastUpdated = entity.lastUpdated ?? Date()
    }
}

// MARK: - CoreData Entities (Auto-generated from WeatherModel.xcdatamodeld)
// You need to create WeatherModel.xcdatamodeld and the CityWeatherEntity.
// Xcode will then automatically generate CityWeatherEntity.swift for you.
// Make sure Codegen is set to 'Class Definition' for CityWeatherEntity in the .xcdatamodeld file inspector.
//
