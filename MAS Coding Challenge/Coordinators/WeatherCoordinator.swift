//
//  ServiceCoordinator.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import SwiftUI
import Combine
import CoreLocation

/*
 The WeatherCoordinator class is responsible for managing the flow of the app--I implemented it this way to separate the navigation logic from the view and view model.
 It uses the Coordinator pattern, which is great for managing complex navigation flows.
 I'm observing the location authorization status to determine whether to show the main weatherview or the permissionview.
 This approach keeps the UI responsive to changes in location permissions.
*/
class WeatherCoordinator: ObservableObject {
    @Published var showingPermissionView = false
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    
    init(locationManager: LocationManager = LocationManager()) {
        self.locationManager = locationManager
        setupLocationStatusObserver()
    }
    
    func start(weatherViewModel: WeatherViewModel) -> some View {
        Group {
            if showingPermissionView {
                LocationPermissionView(locationManager: locationManager)
            } else {
                WeatherView()
                    .environmentObject(weatherViewModel)
            }
        }
    }
    
    private func setupLocationStatusObserver() {
        locationManager.$authorizationStatus
            .sink { [weak self] status in
                switch status {
                case .notDetermined:
                    self?.showingPermissionView = true
                case .restricted, .denied:
                    self?.showingPermissionView = false
                case .authorizedWhenInUse, .authorizedAlways:
                    self?.showingPermissionView = false
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}
