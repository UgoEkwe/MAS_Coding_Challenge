//
//  WeatherViewModelTests.swift
//  MAS Coding ChallengeTests
//
//  Created by Ugonna Oparaochaekwe on 10/1/24.
//

import XCTest
import Combine
import CoreLocation
@testable import MAS_Coding_Challenge

class WeatherViewModelTests: XCTestCase {
    var viewModel: WeatherViewModel!
    var mockWeatherService: MockWeatherService!
    var mockLocationManager: MockLocationManager!
    
    override func setUp() {
        super.setUp()
        mockWeatherService = MockWeatherService()
        mockLocationManager = MockLocationManager()
        viewModel = WeatherViewModel(weatherService: mockWeatherService, locationManager: mockLocationManager)
    }

    func testFetchWeatherForCurrentLocationSuccess() async {
        await viewModel.fetchWeatherForCurrentLocation()
        
        XCTAssertNil(viewModel.currentWeather)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testFetchWeatherForCurrentLocationFailure() async {
        await viewModel.fetchWeatherForCurrentLocation()
        
        XCTAssertNil(viewModel.currentWeather)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Invalid response from server")
    }
    
    func testFetchGeocodingSuggestionsSuccess() async {
        let mockCities = [City(name: "San Francisco", country: "US", state: "CA", lat: 37.7749, lon: -122.4194)]
        mockWeatherService.mockCities = mockCities
        
        await viewModel.fetchGeocodingSuggestions(for: "San Francisco")
        
        XCTAssertEqual(viewModel.suggestions, mockCities)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchGeocodingSuggestionsFailure() async {
        mockWeatherService.mockCities = []
        
        await viewModel.fetchGeocodingSuggestions(for: "Phuong")
        
        XCTAssertEqual(viewModel.suggestions, [])
        XCTAssertNotNil(WeatherError.invalidResponse)
    }
}

class MockWeatherService: WeatherServiceProtocol {
    var mockWeatherResponse: WeatherResponse?
    var mockCities: [City] = []
    
    func fetchWeather(for location: CLLocation) async throws -> WeatherResponse {
        if let response = mockWeatherResponse {
            return response
        }
        throw WeatherError.invalidResponse
    }
    
    func fetchGeocodingSuggestions(for query: String) async throws -> [City] {
        return mockCities
    }
}

class MockLocationManager: LocationManager {
    var mockLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
    
    override func getCurrentLocation() async throws -> CLLocation {
        return mockLocation
    }
}
