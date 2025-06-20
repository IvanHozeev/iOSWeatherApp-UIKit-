//
//  CityCell.swift
//  WeatherApp
//
//  Created by Ivan Khozeyev on 20.06.25.
//


// MARK: - CityCell (UITableViewCell)

import UIKit

class CityCell: UITableViewCell {
    static let reuseIdentifier = "CityCell"

    private let cityNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        return label
    }()

    private let weatherIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        return stack
    }()
    
    private let textStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        textStackView.addArrangedSubview(cityNameLabel)
        textStackView.addArrangedSubview(temperatureLabel)
        
        stackView.addArrangedSubview(weatherIconImageView)
        stackView.addArrangedSubview(textStackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            weatherIconImageView.widthAnchor.constraint(equalToConstant: 60),
            weatherIconImageView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    /// Configures the cell with `CityWeather` data.
    func configure(with cityWeather: CityWeather) {
        cityNameLabel.text = cityWeather.name
        temperatureLabel.text = "טמפ׳: \(String(format: "%.0f°C", cityWeather.temperature))" // Temp: X°C
        
        // Load weather icon from URL
        if let iconURL = URL(string: "\(Constants.openWeatherIconBaseURL)\(cityWeather.weatherIcon)@2x.png") {
            // Use a simple async image loading (could use a library like Kingfisher for production)
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: iconURL), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.weatherIconImageView.image = image
                    }
                } else {
                    // Fallback for missing icon
                    DispatchQueue.main.async {
                        self.weatherIconImageView.image = UIImage(systemName: "cloud.fill") // Placeholder
                    }
                }
            }
        }
    }
}
