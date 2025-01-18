//
//  WeatherManager.swift
//  TrackMyDay
//
//  Created by Pranav Zagade on 11/29/24.
//

import Foundation
import CoreLocation

class WeatherManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let apiKey = "4d75ea1136eb4e0fa6252219243011"
    private let locationManager = CLLocationManager()

    @Published var temperature: String = "--"
    @Published var condition: String = "Fetching weather..."
    @Published var isLoading = true
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func fetchWeather(lat: Double, lon: Double) {
        let urlString = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(lat),\(lon)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }

            do {
                let weatherResponse: WeatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self.temperature = "\(Int(weatherResponse.current.temp_c))°C"
                    self.condition = weatherResponse.current.condition.text
                    self.isLoading = false
                }
            } catch {
                print("Error decoding weather data: \(error.localizedDescription)")
            }
        }.resume()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        self.location = location // Save location for display
        fetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to fetch location: \(error.localizedDescription)")
    }
}
