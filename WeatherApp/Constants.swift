//
//  Constants.swift
//  WeatherApp
//
//  Created by Ivan Khozeyev on 20.06.25.
//

import Foundation

struct Constants {
    // Replace with your actual OpenWeatherMap API Key
    static let openWeatherAPIKey = "YOUR_OPENWEATHERMAP_API_KEY"
    static let openWeatherBaseURL = "https://api.openweathermap.org/data/2.5"
    static let openWeatherIconBaseURL = "https://openweathermap.org/img/wn/"

    // Predefined cities for the app
    static let predefinedCities = [
        "Tel Aviv",
        "Jerusalem",
        "London",
        "New York",
        "Paris",
        "Tokyo",
        "Moscow",
        "Rome",
        "Berlin",
        "Sydney"
    ]
}
