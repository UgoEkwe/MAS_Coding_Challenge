//
//  ServiceCoordinator.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import SwiftUI
import Combine

class WeatherCoordinator: ObservableObject, WeatherViewModelDelegate {
    private let weatherService: WeatherServiceProtocol
    private let locationManager: LocationManager
    private let maxRecentSearches = 5
    
    init(weatherService: WeatherServiceProtocol = WeatherService(), locationManager: LocationManager = LocationManager()) {
        self.weatherService = weatherService
        self.locationManager = locationManager
    }
    
    func start() -> some View {
        let viewModel = WeatherViewModel(weatherService: weatherService, locationManager: locationManager)
        viewModel.delegate = self
        
        Task { @MainActor in
            await loadWeather(viewModel: viewModel)
        }
        
        return WeatherView(viewModel: viewModel)
    }
    
    func didFetchWeather(lat: Double, lon: Double) {
        addRecentSearch(lat: lat, lon: lon)
    }
    
    @MainActor
    private func loadWeather(viewModel: WeatherViewModel) async {
        let recentSearches = getRecentSearches()
        
        for search in recentSearches.reversed() {
            let city = City(name: "", country: "", state: "", lat: search.lat, lon: search.lon)
            await viewModel.fetchWeather(for: city)
        }
        
        if recentSearches.isEmpty {
            await loadWeatherForCurrentLocation(viewModel: viewModel)
        }
    }
    
    @MainActor
    private func loadWeatherForCurrentLocation(viewModel: WeatherViewModel) async {
        await withCheckedContinuation { continuation in
            locationManager.requestLocationPermission { granted in
                if granted {
                    self.locationManager.getUserLocation { location in
                        Task {
                            await viewModel.fetchWeatherForLocation(location)
                            continuation.resume()
                        }
                    }
                } else {
                    viewModel.setError(LocationError.permissionDenied)
                    continuation.resume()
                }
            }
        }
    }
}

extension WeatherCoordinator {
    private func getRecentSearches() -> [RecentSearch] {
        if let data = UserDefaults.standard.data(forKey: "recentSearches"),
           let searches = try? JSONDecoder().decode([RecentSearch].self, from: data) {
            return searches
        }
        return []
    }
    
    func addRecentSearch(lat: Double, lon: Double) {
        var searches = getRecentSearches()
        let newSearch = RecentSearch(lat: lat, lon: lon, timestamp: Date())
        
        if let index = searches.firstIndex(where: { $0.lat == lat && $0.lon == lon }) {
            searches.remove(at: index)
        }
        
        searches.insert(newSearch, at: 0)
        
        if searches.count > maxRecentSearches {
            searches = Array(searches.prefix(maxRecentSearches))
        }
        
        if let encoded = try? JSONEncoder().encode(searches) {
            UserDefaults.standard.set(encoded, forKey: "recentSearches")
        }
    }
}
