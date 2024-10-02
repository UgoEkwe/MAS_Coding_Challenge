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

/*
 The WeatherViewModel is responsible for fetching and storing weather data, managing recent searches, and handling user input. 
 I've used Combine for reactive programming, setting up observers for location changes and user queries. This approach keeps our UI responsive and our data fresh.
 I use @AppStorage and string parsing to persist recent searches across app launches
 --If a user does not allow us their location and they've searched before, their 5 most recent searches are displayed, if they haven't made a search then we display 5 popular cities.
 Every new search is cached in a '/' delimited string
 The user's preferred system of unit is also cached.
*/
class WeatherViewModel: ObservableObject {
    @Published var query = ""
    @Published var suggestions: [City] = []
    @Published var currentWeather: WeatherResponse?
    @Published var recentList: [WeatherResponse] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    @AppStorage("recentSearches") private(set) var recentSearches: String = ""
    @AppStorage("selectedSystem") var selectedSystem: String = "imperial"

    private var cancellables = Set<AnyCancellable>()
    let weatherService: WeatherServiceProtocol
    private let locationManager: LocationManager

    init(weatherService: WeatherServiceProtocol, locationManager: LocationManager) {
        self.weatherService = weatherService
        self.locationManager = locationManager

        setupLocationObserver()
        setupQueryObserver()
        Task { @MainActor [weak self] in
            await self?.loadCache()
        }
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
    
    func loadCache() async {
        if recentSearches.isEmpty {
            for city in Constants.majorCities {
                await self.fetchWeatherForLocation(CLLocation(latitude: city.lat, longitude: city.lon))
            }
        } else {
            await self.loadLastSearchWeather()
        }
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
    func fetchWeatherForCurrentLocation() async {
        self.isLoading = true
        do {
            let location = try await locationManager.getCurrentLocation()
            self.currentWeather = try await weatherService.fetchWeather(for: location)
        } catch {
            setError(error)
        }
        self.isLoading = false
    }

    @MainActor
    func fetchWeatherForLocation(_ location: CLLocation) async {
        self.isLoading = true
        do {
            let newSearch = try await weatherService.fetchWeather(for: location)
            recentList.insert(newSearch, at: 0)
            errorMessage = nil
            
            let newSearchString = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            if !recentSearches.isEmpty {
                recentSearches = "\(newSearchString)/\(recentSearches)"
            } else {
                recentSearches = newSearchString
            }
            
            let searches = recentSearches.split(separator: "/")
            if searches.count > 5 {
                recentSearches = searches.prefix(5).joined(separator: "/")
            }
        } catch {
            setError(error)
        }
        self.isLoading = false
    }
    
    @MainActor
    func loadLastSearchWeather() async {
        let locations = recentSearches.split(separator: "/")
        for location in locations {
            let coordinates = location.split(separator: ",")
            if coordinates.count == 2,
               let lat = Double(coordinates[0]),
               let lon = Double(coordinates[1]) {
                do {
                    let search = try await weatherService.fetchWeather(for: CLLocation(latitude: lat, longitude: lon))
                    recentList.append(search)
                } catch {
                    print("Failed to load last search weather: \(error)")
                }
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
