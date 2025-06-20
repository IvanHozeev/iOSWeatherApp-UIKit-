//
//  WeatherAPIClientProtocol.swift
//  WeatherApp
//
//  Created by Ivan Khozeyev on 20.06.25.
//

import Foundation

// MARK: - API Client Protocol

/// Protocol for the weather API client.
protocol WeatherAPIClientProtocol {
    func fetchCurrentWeather(forCity city: String) async throws -> OpenWeatherResponse
    func fetchCurrentWeather(forCities cities: [String]) async throws -> [OpenWeatherResponse]
    func getWeatherIconURL(iconCode: String) -> URL?
}
