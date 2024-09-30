//
//  WeatherViewModel.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import Foundation
import CoreLocation
import Combine

class WeatherViewModel: ObservableObject {
    @Published var query = ""
    @Published var suggestions: [City] = []
    @Published var weather: WeatherResponse?
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let weatherService: WeatherServiceProtocol
    private let locationManager: LocationManager

    init(weatherService: WeatherServiceProtocol, locationManager: LocationManager) {
        self.weatherService = weatherService
        self.locationManager = locationManager
        setupQueryObserver()
    }

    private func setupQueryObserver() {
        $query
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard !query.isEmpty else {
                    self?.suggestions = []
                    return
                }
                Task { [weak self] in
                    await self?.fetchGeocodingSuggestions(for: query)
                }
            }
            .store(in: &cancellables)
    }

    @MainActor
    func fetchGeocodingSuggestions(for query: String) async {
        do {
            suggestions = try await weatherService.fetchGeocodingSuggestions(for: query)
            errorMessage = nil
        } catch {
            if let weatherError = error as? WeatherError {
                errorMessage = weatherError.message
            } else {
                errorMessage = error.localizedDescription
            }
            suggestions = []
        }
    }

    @MainActor
    func fetchWeather(for city: City) async {
        UserDefaults.standard.set(city.lat, forKey: "lastSearchLat")
        UserDefaults.standard.set(city.lon, forKey: "lastSearchLon")
        do {
            weather = try await weatherService.fetchWeather(for: city)
            errorMessage = nil
        } catch {
            if let weatherError = error as? WeatherError {
                errorMessage = weatherError.message
            } else {
                errorMessage = error.localizedDescription
            }
            weather = nil
        }
    }

    @MainActor
    func fetchWeatherForLocation(_ location: CLLocation) async {
        UserDefaults.standard.set(Double(location.coordinate.latitude), forKey: "lastSearchLat")
        UserDefaults.standard.set(Double(location.coordinate.longitude), forKey: "lastSearchLon")
        do {
            weather = try await weatherService.fetchWeather(for: location)
            errorMessage = nil
        } catch {
            if let weatherError = error as? WeatherError {
                errorMessage = weatherError.message
            } else {
                errorMessage = error.localizedDescription
            }
            weather = nil
        }
    }
}

extension WeatherViewModel {
    @MainActor
    func setError(_ error: Error) {
        if let weatherError = error as? WeatherError {
            errorMessage = weatherError.message
        } else {
            errorMessage = error.localizedDescription
        }
    }
}
