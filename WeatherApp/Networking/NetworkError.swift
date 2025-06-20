//
//  NetworkError.swift
//  WeatherApp
//
//  Created by Ivan Khozeyev on 20.06.25.
//

import Foundation

// MARK: - Network Error Enum

/// Custom error types for network operations.
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case noInternetConnection
    case customError(String) // For server-side custom errors
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "כתובת ה-URL אינה תקינה." // Invalid URL address.
        case .requestFailed(let error): return "הבקשה נכשלה: \(error.localizedDescription)" // Request failed
        case .invalidResponse: return "תגובת שרת לא חוקית." // Invalid server response
        case .decodingFailed(let error): return "כשל בפענוח הנתונים: \(error.localizedDescription)" // Data decoding failed
        case .noInternetConnection: return "אין חיבור לאינטרנט. מוצגים נתונים אחרונים." // No internet connection. Displaying last cached data.
        case .customError(let message): return message // Custom error message
        }
    }
}
