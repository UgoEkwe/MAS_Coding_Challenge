//
//  WeatherViewModel.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import Foundation
import CoreLocation
import Combine

protocol WeatherViewModelDelegate: AnyObject {
    func didFetchWeather(lat: Double, lon: Double)
}

class WeatherViewModel: ObservableObject {
    @Published var query = ""
    @Published var suggestions: [City] = []
    @Published var weather: WeatherResponse?
    @Published var recentSearches: [WeatherResponse] = []
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let weatherService: WeatherServiceProtocol
    private let locationManager: LocationManager
    weak var delegate: WeatherViewModelDelegate?

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
        do {
            let newSearch = try await weatherService.fetchWeather(for: city)
            updateWeather(newSearch)
            errorMessage = nil
            delegate?.didFetchWeather(lat: city.lat, lon: city.lon)
        } catch {
            setError(error)
        }
    }

    @MainActor
    func fetchWeatherForLocation(_ location: CLLocation) async {
        do {
            let newSearch = try await weatherService.fetchWeather(for: location)
            updateWeather(newSearch)
            errorMessage = nil
            delegate?.didFetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        } catch {
            setError(error)
        }
    }

    private func updateWeather(_ newSearch: WeatherResponse) {
        if weather == nil {
            weather = newSearch
        }
        if let index = recentSearches.firstIndex(where: { $0.id == newSearch.id }) {
            recentSearches.remove(at: index)
        }
        recentSearches.insert(newSearch, at: 0)
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
