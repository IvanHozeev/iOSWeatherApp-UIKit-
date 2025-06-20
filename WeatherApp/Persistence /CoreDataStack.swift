//
//  CoreDataStack.swift
//  WeatherApp
//
//  Created by Ivan Khozeyev on 20.06.25.
//

import Foundation
import CoreData

// MARK: - CoreData Stack

/// Singleton class to manage the CoreData stack.
final class CoreDataStack {
    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WeatherModel") // Ensure this matches your .xcdatamodeld file name
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    /// Saves changes in the managed object context.
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
