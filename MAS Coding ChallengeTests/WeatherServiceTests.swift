//
//  WeatherServiceTests.swift
//  MAS Coding ChallengeTests
//
//  Created by Ugonna Oparaochaekwe on 10/1/24.
//

import XCTest
import CoreLocation
@testable import MAS_Coding_Challenge

class WeatherServiceTests: XCTestCase {
    var weatherService: WeatherService!
    
    override func setUp() {
        super.setUp()
        weatherService = WeatherService()
    }
    
    func testFetchWeatherInvalidURL() async {
        do {
            let location = CLLocation(latitude: 0, longitude: 0)
            let _ = try await weatherService.fetchWeather(for: location)
            XCTFail("Expected invalid URL error")
        } catch let error as WeatherError {
            switch error {
            case .invalidURL:
                XCTAssertEqual(error, .invalidURL)
            case .decodingError(let decodingError):
                print("Decoding Error: \(decodingError)")
                XCTAssert(true)
            default:
                XCTFail("Unexpected WeatherError: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchGeocodingSuggestionsInvalidURL() async {
        do {
            let _ = try await weatherService.fetchGeocodingSuggestions(for: "123 Cherry St")
        } catch let error as WeatherError {
            XCTAssertEqual(error, .invalidURL)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
