//
//  PersistenceServiceProtocol.swift
//  WeatherApp
//
//  Created by Ivan Khozeyev on 20.06.25.
//

import Foundation

// MARK: - Persistence Service Protocol

/// Protocol for weather data persistence operations.
protocol WeatherPersistenceServiceProtocol {
    func saveWeather(cityWeather: CityWeather) throws
    func saveWeathers(cityWeathers: [CityWeather]) throws
    func fetchAllSavedWeathers() throws -> [CityWeather]
    func deleteAllWeathers() throws
}
