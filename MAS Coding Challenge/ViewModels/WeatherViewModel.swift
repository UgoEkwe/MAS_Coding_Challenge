//
//  WeatherViewModel.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import Foundation
import CoreLocation
import Combine
import SwiftUI

protocol WeatherViewModelDelegate: AnyObject {
    func didFetchWeather(lat: Double, lon: Double)
}

class WeatherViewModel: ObservableObject {
    @Published var query = ""
    @Published var suggestions: [City] = []
    @Published var weather: WeatherResponse?
    @Published var currentWeather: WeatherResponse?
    @Published var lastSearchWeather: WeatherResponse?
    @Published var errorMessage: String?
    @AppStorage("lastSearch") private(set) var lastSearch: String = ""

    private var cancellables = Set<AnyCancellable>()
    let weatherService: WeatherServiceProtocol
    private let locationManager: LocationManager
    weak var delegate: WeatherViewModelDelegate?

    init(weatherService: WeatherServiceProtocol, locationManager: LocationManager) {
        self.weatherService = weatherService
        self.locationManager = locationManager

        setupLocationObserver()
        setupQueryObserver()
    }

    private func setupLocationObserver() {
        locationManager.$authorizationStatus
            .dropFirst()
            .sink { [weak self] newStatus in
                if newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways {
                    Task { @MainActor [weak self] in
                        await self?.fetchWeatherForCurrentLocation()
                    }
                }
            }
            .store(in: &cancellables)
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
            setError(error)
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
    func fetchWeatherForCurrentLocation() async {
        do {
            let location = try await locationManager.getCurrentLocation()
            self.currentWeather = try await weatherService.fetchWeather(for: location)
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
        weather = newSearch
    }

    func updateLastSearch(lat: Double, lon: Double) {
        lastSearch = "\(lat),\(lon)"
    }

    @MainActor
    func loadLastSearchWeather() async {
        let coordinates = lastSearch.split(separator: ",")
        if coordinates.count == 2,
           let lat = Double(coordinates[0]),
           let lon = Double(coordinates[1]) {
            do {
                lastSearchWeather = try await weatherService.fetchWeather(for: CLLocation(latitude: lat, longitude: lon))
            } catch {
                print("Failed to load last search weather: \(error)")
            }
        }
    }
}

extension WeatherViewModel {
    @MainActor
    private func setError(_ error: Error) {
        if let weatherError = error as? WeatherError {
            errorMessage = weatherError.message
        } else {
            errorMessage = error.localizedDescription
        }
    }
}
