# iOS Weather App
### A simple iOS weather application displaying a list of cities with current weather data, and the ability to view more details for each city. The application supports offline mode by saving data locally.

## 1. Project Structure
### The project is organized into several logical groups to maintain clean, modular, and easily maintainable code.

WeatherApp/

        AppDelegate.swift

        SceneDelegate.swift

        Constants.swift // Constant definitions, such as API key and city list.

            Models/ // Data models for API responses and in-app data representation.

        Models.swift // Consolidated data models (e.g., OpenWeatherResponse, CityWeather).

            Navigation/ // Navigation flow management.

        MainCoordinator.swift // Main coordinator managing navigation between screens.

            Networking/ // Network services and clients.

        NetworkError.swift // Enum for custom network error types.

        OpenWeatherAPIClientProtocol.swift // Protocol for the OpenWeatherMap API client.

        OpenWeatherAPIClient.swift // API client for making calls to OpenWeatherMap.

            Persistence/ // Local data storage.

        WeatherModel.xcdatamodeld // CoreData data model.

        CoreDataStack.swift // Singleton for managing the CoreData stack.

        WeatherPersistenceService.swift // Service for saving/loading weather data using CoreData.

            ViewModels/ // View Models containing presentation logic and state for View Controllers.

        CityListViewModel.swift // ViewModel for the city list screen.

        CityDetailViewModel.swift // ViewModel for the city detail screen.

            Views/ // The application's View Controllers.

        CityListViewController.swift // Displays a list of cities with weather.

        CityCell.swift // Custom cell for the city table view.

        CityDetailViewController.swift // Displays full weather details for a city.


## 2. Technical and Architectural Choices
### The application is developed using the following key technologies and architectural patterns:

#### `UIKit`: 
##### Chosen as the UI framework, with all user interface elements created programmatically.

#### `MVVM-C` (Model-View-ViewModel + Coordinator):

#### `MVVM`: 
##### The primary architectural pattern, ensuring a clear separation between View, ViewModel, and Model, which improves testability and code manageability. View Controllers remain "dumb," while View Models contain presentation logic and state, using @Published for reactive UI updates.

#### `Coordinator`: 
##### This pattern is used to manage the navigation flow, decoupling navigation logic from View Controllers and making them more modular.

#### `URLSession` (with `Swift Concurrency`): 
##### Used for performing network calls. async/await ensures clean and safe asynchronous code, and TaskGroup allows for parallel data loading for multiple cities, enhancing performance.

#### `Codable`: 
##### Used for decoding JSON responses from the OpenWeatherMap API into Swift models, ensuring safe and efficient data processing.

#### `CoreData`: 
##### Chosen for local storage of structured data (city and weather information). It provides efficient saving, retrieval, and updating of large volumes of data, and supports offline operation.

#### `Network.framework` (`NWPathMonitor`): 
##### Applied for monitoring the network connection status, allowing the application to react to network changes (e.g., entering offline mode or refreshing data upon connection restoration).

#### `Combine`: 
##### Used in View Models (with @Published and .sink) for reactive UI updates when the View Model's state changes.

## 3. Installation and Running Instructions
To run the project, follow these instructions:

 Prerequisites

    Xcode: Version 14 or later.

    Swift: Version 5.7 or later.

    Package Managers (CocoaPods / Swift Package Manager): External package managers are not required; the project uses only built-in Apple APIs.

    OpenWeatherMap API Key: You must register on the OpenWeatherMap website and obtain a personal API key. A free key is usually sufficient for testing purposes.

Installation and Running Steps

Clone the Repository:
Open `Terminal` and navigate to the directory where you want to save the project. Then, execute the following command:

    git clone <URL_of_your_GitHub_repository>
    cd WeatherApp


Insert `OpenWeatherMap API Key`:

Open the project in Xcode.

Navigate to the `Constants.swift` file (under the `Utilities` group).

Find the line:

    static let openWeatherAPIKey = "YOUR_OPENWEATHERMAP_API_KEY"


Replace `"YOUR_OPENWEATHERMAP_API_KEY"` with your actual `API key`. For example:

    static let openWeatherAPIKey = "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6"


Configure CoreData Model:

In the `Xcode Navigator` (left panel), navigate to the `WeatherModel.xcdatamodeld` file (under the `Persistence` group).

Ensure that the name of the `.xcdatamodeld` file precisely matches the name specified in `NSPersistentContainer(name: "WeatherModel")` within the `CoreDataStack.swift` file. The name must match exactly, including case (e.g., "`WeatherModel`" is not the same as "`weathermodel`").

Check Target Membership: Select `WeatherModel.xcdatamodeld` in the `Xcode Navigator`. In the right panel (`File Inspector`), under the "`Target Membership`" section, ensure that the checkbox next to your main application target (usually "`WeatherApp`") is checked.

Ensure that an entity named `CityWeatherEntity` is created with the following attributes (Type / Name):

    id: Integer 64 (int64) - Primary Key, Not Optional

    name: String - Not Optional

    temperature: Double

    tempMin: Double

    tempMax: Double

    humidity: Integer 16 (int16)

    windSpeed: Double

    weatherIcon: String

    weatherDescription: String

    lastUpdated: Date

 Ensure that `Codegen` for `CityWeatherEntity` is set to `Class Definition` in the `Data Model Inspector` (right panel).

 `Build` and `Run` the Application:

 Clean the project and reinstall the app: In `Xcode`, select `Product > Clean Build Folder`. Then, delete the app from the simulator or real device (press and hold the app icon,       then select "Delete App").

 Select an `iOS simulator` (e.g., iPhone 15 Pro) or connect a real iOS device.

 Click the "`Run`" button (arrow) in `Xcode`, or go to `Product > Run`.

 Xcode will build the project and launch the application on your selected `simulator/device`.
