//
//  CityListViewController.swift
//  WeatherApp
//
//  Created by Ivan Khozeyev on 20.06.25.
//

import UIKit
import Combine

// MARK: - CityListViewController

/// View Controller for displaying a list of cities and their current weather.
class CityListViewController: UIViewController {

    private var viewModel: any CityListViewModelProtocol // ViewModel is injected
    private var coordinator: MainCoordinatorProtocol? // Coordinator is injected

    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var cancellables = Set<AnyCancellable>() // For Combine subscriptions

    /// Initializes the view controller with a view model and coordinator.
    init(viewModel: any CityListViewModelProtocol, coordinator: MainCoordinatorProtocol) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.fetchWeatherForAllCities() // Initial data fetch
    }

    /// Sets up the user interface elements.
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "מזג אוויר בערים" // Weather in Cities

        // Setup UITableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CityCell.self, forCellReuseIdentifier: CityCell.reuseIdentifier)
        view.addSubview(tableView)

        // Setup activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Add refresh control to table view
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWeatherData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    /// Sets up bindings between ViewModel and View Controller.
    private func setupBindings() {
        // Subscribe to citiesWeather changes
        viewModel.citiesWeatherPublisher
            .receive(on: DispatchQueue.main) // Ensure UI updates on main thread
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.tableView.refreshControl?.endRefreshing() // End refresh animation
            }
            .store(in: &cancellables)

        // Subscribe to isLoading changes
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
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
        
        // Subscribe to isOffline changes (for showing a persistent warning if needed)
        viewModel.isOfflinePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isOffline in
                if isOffline {
                    self?.showAlert(title: "מצב לא מקוון", message: NetworkError.noInternetConnection.localizedDescription)
                }
            }
            .store(in: &cancellables)
    }
    
    /// Handles refresh control action.
    @objc private func refreshWeatherData() {
        viewModel.fetchWeatherForAllCities()
    }

    /// Displays an alert message to the user.
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "אישור", style: .default, handler: nil)) // OK button
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension CityListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.citiesWeather.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CityCell.reuseIdentifier, for: indexPath) as? CityCell else {
            return UITableViewCell()
        }
        let cityWeather = viewModel.citiesWeather[indexPath.row]
        cell.configure(with: cityWeather)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CityListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCity = viewModel.citiesWeather[indexPath.row]
        coordinator?.navigateToDetail(forCity: selectedCity.name) // Navigate using coordinator
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 // Adjust row height as needed
    }
}
