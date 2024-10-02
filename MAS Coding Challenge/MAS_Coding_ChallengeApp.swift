//
//  MAS_Coding_ChallengeApp.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import SwiftUI

/*
 Here I set up the dependency injection and create the view model and coordinator.
 By initializing these objects here, we ensure they're available throughout the app's lifecycle.
 The use of @StateObject ensures that these objects persist across view updates.
*/
@main
struct WeatherApp: App {
    @StateObject private var weatherViewModel: WeatherViewModel
    @StateObject private var coordinator: WeatherCoordinator
    
    init() {
        let weatherService = WeatherService()
        let locationManager = LocationManager()
        let viewModel = WeatherViewModel(weatherService: weatherService, locationManager: locationManager)
        
        _weatherViewModel = StateObject(wrappedValue: viewModel)
        _coordinator = StateObject(wrappedValue: WeatherCoordinator())
    }
    
    var body: some Scene {
        WindowGroup {
            coordinator.start(weatherViewModel: weatherViewModel)
        }
    }
}

