//
//  ServiceCoordinator.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import SwiftUI
import Combine
import CoreLocation
class WeatherCoordinator: ObservableObject, WeatherViewModelDelegate {
    @Published var showingPermissionView = false
    @Published var weatherViewModel: WeatherViewModel?
    
    private let weatherService: WeatherServiceProtocol
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    
    init(weatherService: WeatherServiceProtocol = WeatherService(), locationManager: LocationManager = LocationManager()) {
        self.weatherService = weatherService
        self.locationManager = locationManager
        
        setupLocationStatusObserver()
    }
    
    private func setupLocationStatusObserver() {
        locationManager.$authorizationStatus
            .sink { [weak self] status in
                switch status {
                case .notDetermined:
                    self?.showingPermissionView = true
                case .restricted, .denied:
                    self?.showingPermissionView = false
                    self?.loadWeatherForMajorCities()
                case .authorizedWhenInUse, .authorizedAlways:
                    self?.showingPermissionView = false
                    self?.loadWeatherForCurrentLocation()
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func start() -> some View {
        Group {
            if showingPermissionView {
                LocationPermissionView(locationManager: locationManager)
            } else if let viewModel = weatherViewModel {
                WeatherView(viewModel: viewModel)
                    .task {
                        await viewModel.loadLastSearchWeather()
                    }
            }
        }
    }
    
    func didFetchWeather(lat: Double, lon: Double) {
        weatherViewModel?.updateLastSearch(lat: lat, lon: lon)
    }
    
    private func loadWeatherForCurrentLocation() {
        Task { @MainActor in
            do {
                let location = try await locationManager.getCurrentLocation()
                createAndConfigureViewModel()
                await weatherViewModel?.fetchWeatherForCurrentLocation()
            } catch {
                print("Failed to get current location: \(error.localizedDescription)")
                loadWeatherForMajorCities()
            }
        }
    }
    
    private func loadWeatherForMajorCities() {
        Task { @MainActor in
            createAndConfigureViewModel()
            for city in Constants.majorCities {
                await weatherViewModel?.fetchWeather(for: city)
                if weatherViewModel?.currentWeather != nil {
                    break
                }
            }
        }
    }
    
    private func createAndConfigureViewModel() {
        weatherViewModel = WeatherViewModel(weatherService: weatherService, locationManager: locationManager)
        weatherViewModel?.delegate = self
    }
}
