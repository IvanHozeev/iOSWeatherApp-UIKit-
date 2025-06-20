//
//  MainCoordinator.swift
//  WeatherApp
//
//  Created by Ivan Khozeyev on 20.06.25.
//

// MARK: - Coordinators.swift

import Foundation
import UIKit

// MARK: - Coordinator Protocols

/// Base protocol for all coordinators.
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    func start()
}

/// Protocol for the main coordinator, defining navigation flows specific to the app.
protocol MainCoordinatorProtocol: Coordinator {
    func navigateToDetail(forCity cityName: String)
}

// MARK: - Main Coordinator

/// Main coordinator responsible for application's primary navigation flow.
class MainCoordinator: MainCoordinatorProtocol {
    var navigationController: UINavigationController

    private let weatherAPIClient: WeatherAPIClientProtocol
    private let persistenceService: WeatherPersistenceServiceProtocol

    /// Initializes the coordinator.
    init(navigationController: UINavigationController,
         weatherAPIClient: WeatherAPIClientProtocol,
         persistenceService: WeatherPersistenceServiceProtocol) {
        self.navigationController = navigationController
        self.weatherAPIClient = weatherAPIClient
        self.persistenceService = persistenceService
    }

    /// Starts the main flow by presenting the city list.
    func start() {
        let viewModel = CityListViewModel(weatherAPIClient: weatherAPIClient, persistenceService: persistenceService)
        let viewController = CityListViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(viewController, animated: false)
    }

    /// Navigates to the city detail screen.
    /// - Parameter cityName: The name of the city for which to show details.
    func navigateToDetail(forCity cityName: String) {
        let viewModel = CityDetailViewModel(
            cityName: cityName,
            weatherAPIClient: weatherAPIClient,
            persistenceService: persistenceService
        )
        let viewController = CityDetailViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
