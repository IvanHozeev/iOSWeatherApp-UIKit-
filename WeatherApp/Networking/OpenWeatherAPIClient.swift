//
//  OpenWeatherAPIClient.swift
//  WeatherApp
//
//  Created by Ivan Khozeyev on 20.06.25.
//

import Foundation

// MARK: - OpenWeatherMap API Client

/// Implementation of `WeatherAPIClientProtocol`.
class OpenWeatherAPIClient: WeatherAPIClientProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Fetches current weather data for a single city.
    /// - Parameter city: The name of the city.
    /// - Returns: `OpenWeatherResponse` containing weather data.
    /// - Throws: `NetworkError` if the request fails or data cannot be decoded.
    func fetchCurrentWeather(forCity city: String) async throws -> OpenWeatherResponse {
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw NetworkError.invalidURL
        }
        let urlString = "\(Constants.openWeatherBaseURL)/weather?q=\(encodedCity)&appid=\(Constants.openWeatherAPIKey)&units=metric&lang=he"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse(statusCode: 0, data: nil) // Не HTTP ответ
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                let responseBody = String(data: data, encoding: .utf8)
                print("--- API Response Error for \(city) ---")
                print("Status Code: \(httpResponse.statusCode)")
                print("Response Body: \(responseBody ?? "No Data")")
                print("---------------------------------")
                throw NetworkError.invalidResponse(statusCode: httpResponse.statusCode, data: responseBody)
            }

            let decoder = JSONDecoder()
            let weatherResponse = try decoder.decode(OpenWeatherResponse.self, from: data)
            return weatherResponse
        } catch let decodingError as DecodingError {
            print("Decoding Error for city \(city): \(decodingError)")
            throw NetworkError.decodingFailed(decodingError)
        } catch {
            print("Network Request Failed for city \(city): \(error)")
            throw NetworkError.requestFailed(error)
        }
    }

    /// Fetches current weather data for a list of cities concurrently.
    /// - Parameter cities: An array of city names.
    /// - Returns: An array of `OpenWeatherResponse` for each successfully fetched city.
    /// - Throws: `NetworkError` if any request fails.
    func fetchCurrentWeather(forCities cities: [String]) async throws -> [OpenWeatherResponse] {
        var responses: [OpenWeatherResponse] = []
        var errors: [Error] = []

        // Use a TaskGroup to fetch data for multiple cities concurrently
        await withTaskGroup(of: Result<OpenWeatherResponse, Error>.self) { group in
            for city in cities {
                group.addTask {
                    do {
                        let response = try await self.fetchCurrentWeather(forCity: city)
                        return .success(response)
                    } catch {
                        return .failure(error)
                    }
                }
            }

            for await result in group {
                switch result {
                case .success(let response):
                    responses.append(response)
                case .failure(let error):
                    errors.append(error)
                }
            }
        }
        
        // If there are errors, you might choose to throw the first one
        // or return partial results and log errors.
        if let firstError = errors.first {
            throw firstError // Throwing the first error encountered
        }
        
        return responses
    }

    /// Constructs the URL for a weather icon.
    /// - Parameter iconCode: The icon code from OpenWeatherMap API (e.g., "04n").
    /// - Returns: An optional `URL` for the icon image.
    func getWeatherIconURL(iconCode: String) -> URL? {
        return URL(string: "\(Constants.openWeatherIconBaseURL)\(iconCode)@2x.png")
    }
}
