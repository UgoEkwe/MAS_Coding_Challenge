//
//  ServiceCoordinator.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import SwiftUI
import Combine

class WeatherCoordinator: ObservableObject {
    private let weatherService: WeatherServiceProtocol
    private let locationManager: LocationManager
    
    init(weatherService: WeatherServiceProtocol = WeatherService(), locationManager: LocationManager = LocationManager()) {
        self.weatherService = weatherService
        self.locationManager = locationManager
    }
    
    func start() -> some View {
        let viewModel = WeatherViewModel(weatherService: weatherService, locationManager: locationManager)
        
        Task { @MainActor in
            await loadWeather(viewModel: viewModel)
        }
        
        return WeatherView(viewModel: viewModel)
    }
    
    @MainActor
    private func loadWeather(viewModel: WeatherViewModel) async {
        let lastLat = UserDefaults.standard.double(forKey: "lastSearchLat")
        let lastLon = UserDefaults.standard.double(forKey: "lastSearchLon")
        
        if lastLat != 0 && lastLon != 0 {
            let lastCity = City(name: "", country: "", state: "", lat: lastLat, lon: lastLon)
            await viewModel.fetchWeather(for: lastCity)
        } else {
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
