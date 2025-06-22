//
//  CityDetailViewController.swift
//  WeatherApp
//
//  Created by Ivan Khozeyev on 20.06.25.
//

import UIKit
import Combine

// MARK: - CityDetailViewController

/// View Controller for displaying detailed weather information for a selected city.
class CityDetailViewController: UIViewController {

    private var viewModel: any CityDetailViewModelProtocol // ViewModel is injected
    
    // UI Elements
    private let cityNameLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let weatherDescriptionLabel = UILabel()
    private let weatherIconImageView = UIImageView()
    private let minMaxTemperatureLabel = UILabel()
    private let humidityLabel = UILabel()
    private let windSpeedLabel = UILabel()
    private let lastUpdatedLabel = UILabel()
    
    private let refreshButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private var cancellables = Set<AnyCancellable>() // For Combine subscriptions

    /// Initializes the view controller with a view model.
    init(viewModel: any CityDetailViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.fetchWeatherDetails() // Fetch details for this city
    }

    /// Sets up the user interface elements.
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = viewModel.cityName // Set title to city name

        // Labels setup
        cityNameLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        temperatureLabel.font = UIFont.systemFont(ofSize: 60, weight: .bold)
        weatherDescriptionLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        minMaxTemperatureLabel.font = UIFont.preferredFont(forTextStyle: .body)
        humidityLabel.font = UIFont.preferredFont(forTextStyle: .body)
        windSpeedLabel.font = UIFont.preferredFont(forTextStyle: .body)
        lastUpdatedLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        lastUpdatedLabel.textColor = .secondaryLabel

        weatherIconImageView.contentMode = .scaleAspectFit
        weatherIconImageView.translatesAutoresizingMaskIntoConstraints = false
        weatherIconImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        weatherIconImageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        // Refresh Button
        refreshButton.setTitle("רענן", for: .normal) // Refresh
        refreshButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)

        // Activity Indicator
        activityIndicator.hidesWhenStopped = true

        // Create a vertical stack view for all details
        let stackView = UIStackView(arrangedSubviews: [
            cityNameLabel,
            temperatureLabel,
            weatherDescriptionLabel,
            weatherIconImageView,
            minMaxTemperatureLabel,
            humidityLabel,
            windSpeedLabel,
            lastUpdatedLabel,
            refreshButton,
            activityIndicator
        ])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    /// Sets up bindings between ViewModel and View Controller.
    private func setupBindings() {
        // Subscribe to cityWeather changes
        viewModel.cityWeatherPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] weather in
                self?.updateUI(with: weather)
            }
            .store(in: &cancellables)

        // Subscribe to isLoading changes
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.refreshButton.isEnabled = false // Disable button while loading
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.refreshButton.isEnabled = true
                }
            }
            .store(in: &cancellables)

        // Subscribe to errorMessage changes
        viewModel.errorMessagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                if let message = message, !message.isEmpty {
                    self?.showAlert(title: "שגיאה", message: message) // Error
                }
            }
            .store(in: &cancellables)
    }

    /// Updates the UI with the provided weather data.
    private func updateUI(with weather: CityWeather?) {
        guard let weather = weather else {
            cityNameLabel.text = viewModel.cityName
            temperatureLabel.text = "אין נתונים" // No data
            weatherDescriptionLabel.text = ""
            minMaxTemperatureLabel.text = ""
            humidityLabel.text = ""
            windSpeedLabel.text = ""
            lastUpdatedLabel.text = ""
            weatherIconImageView.image = nil
            return
        }

        cityNameLabel.text = weather.name
        temperatureLabel.text = String(format: "%.0f°C", weather.temperature)
        weatherDescriptionLabel.text = weather.weatherDescription.capitalized
        minMaxTemperatureLabel.text = String(format: "מינימום: %.0f°C, מקסימום: %.0f°C", weather.tempMin, weather.tempMax) // Min: X°C, Max: Y°C
        humidityLabel.text = "לחות: \(weather.humidity)%" // Humidity: X%
        windSpeedLabel.text = String(format: "מהירות רוח: %.1f מ/ש", weather.windSpeed) // Wind Speed: X.X m/s
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        lastUpdatedLabel.text = "עודכן לאחרונה: \(dateFormatter.string(from: weather.lastUpdated))" // Last updated: <date>

        // Load weather icon
        if let iconURL = viewModel.getWeatherIconURL() {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: iconURL), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.weatherIconImageView.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        self.weatherIconImageView.image = UIImage(systemName: "cloud.fill") // Placeholder
                    }
                }
            }
        }
    }
    
    /// Handles the refresh button tap.
    @objc private func refreshButtonTapped() {
        viewModel.fetchWeatherDetails()
    }

    /// Displays an alert message to the user.
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "אישור", style: .default, handler: nil)) // OK
        present(alert, animated: true, completion: nil)
    }
}
