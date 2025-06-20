//
//  WeatherPersistenceService.swift
//  WeatherApp
//
//  Created by Ivan Khozeyev on 20.06.25.
//

import Foundation
import CoreData

// MARK: - Weather Persistence Service

/// Implementation of `WeatherPersistenceServiceProtocol` using CoreData.
class WeatherPersistenceService: WeatherPersistenceServiceProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// Saves a single `CityWeather` object to CoreData, or updates if it already exists.
    /// - Parameter cityWeather: The `CityWeather` object to save.
    func saveWeather(cityWeather: CityWeather) throws {
        // Fetch existing entity or create new
        let fetchRequest: NSFetchRequest<CityWeatherEntity> = CityWeatherEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %lld", Int64(cityWeather.id))

        do {
            let existingEntities = try context.fetch(fetchRequest)
            let entity: CityWeatherEntity
            if let existing = existingEntities.first {
                entity = existing
            } else {
                entity = CityWeatherEntity(context: context)
            }

            // Update entity properties
            entity.id = Int64(cityWeather.id)
            entity.name = cityWeather.name
            entity.temperature = cityWeather.temperature
            entity.tempMin = cityWeather.tempMin
            entity.tempMax = cityWeather.tempMax
            entity.humidity = Int16(cityWeather.humidity)
            entity.windSpeed = cityWeather.windSpeed
            entity.weatherIcon = cityWeather.weatherIcon
            entity.weatherDescription = cityWeather.weatherDescription
            entity.lastUpdated = cityWeather.lastUpdated

            try context.save()
        } catch {
            throw NetworkError.customError("Failed to save weather data: \(error.localizedDescription)")
        }
    }
    
    /// Saves an array of `CityWeather` objects to CoreData.
    /// This method can be optimized for batch inserts in large datasets.
    /// - Parameter cityWeathers: An array of `CityWeather` objects to save.
    func saveWeathers(cityWeathers: [CityWeather]) throws {
        for weather in cityWeathers {
            try saveWeather(cityWeather: weather)
        }
        CoreDataStack.shared.saveContext() // Save context once after all inserts/updates
    }

    /// Fetches all saved `CityWeather` objects from CoreData.
    /// - Returns: An array of `CityWeather` objects.
    func fetchAllSavedWeathers() throws -> [CityWeather] {
        let fetchRequest: NSFetchRequest<CityWeatherEntity> = CityWeatherEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)] // Sort by city name

        do {
            let entities = try context.fetch(fetchRequest)
            return entities.map { CityWeather(entity: $0) }
        } catch {
            throw NetworkError.customError("Failed to fetch weather data: \(error.localizedDescription)")
        }
    }

    /// Deletes all saved `CityWeather` objects from CoreData.
    func deleteAllWeathers() throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CityWeatherEntity")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(batchDeleteRequest)
            try context.save() // Save changes after batch delete
        } catch {
            throw NetworkError.customError("Failed to delete all weather data: \(error.localizedDescription)")
        }
    }
}
