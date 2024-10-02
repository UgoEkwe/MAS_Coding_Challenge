//
//  WeatherService.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import Foundation
import CoreLocation

protocol WeatherServiceError: Error {
    var message: String { get }
}

/*
 The WeatherError enum is a custom error type I created to handle various error scenarios in the weather service
 --I did it this way because it allows for more specific error handling. It initially was meant to provide user-friendly error messages, but I opted to just display a basic message instead.
 The Equatable conformance is particularly useful for testing, as it allows us to compare error instances.
*/
enum WeatherError: WeatherServiceError, Equatable {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case invalidResponse

    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }

    static func == (lhs: WeatherError, rhs: WeatherError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse):
            return true
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.decodingError(let lhsError), .decodingError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

protocol WeatherServiceProtocol {
    func fetchWeather(for location: CLLocation) async throws -> WeatherResponse
    func fetchGeocodingSuggestions(for query: String) async throws -> [City]
}


/*
 The WeatherService class is the core network layer--I structured it this way to encapsulate all API calls and data fetching logic.
 It conforms to WeatherService protocol, which is great for dependency injection and makes it easy to swap out with a mock for testing.
 I've implemented separate methods for fetching weather and geocoding suggestions, keeping the code modular and easier to maintain.
 The error handling is robust, throwing custom WeatherErrors for different failure scenarios.
 I also included string validation for the geocoding suggestions allowing users to search for either cities or zip codes
 --It seemed like the only other way to accoplish this would be a toggle in the search bar but I felt that was unnecessary.
*/
class WeatherService: WeatherServiceProtocol {
    private let apiKey: String
    private let baseURL = "https://api.openweathermap.org"
    
    init() {
        self.apiKey = KeyManager.shared.getAPIKey(for: "WeatherAPIKey") ?? ""
    }
    
    func fetchWeather(for location: CLLocation) async throws -> WeatherResponse {
        let urlString = "\(baseURL)/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)&units=metric"
        return try await fetchWeather(from: urlString)
    }
    
    private func fetchWeather(from urlString: String) async throws -> WeatherResponse {
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                throw WeatherError.invalidResponse
            }
            let decoder = JSONDecoder()
            return try decoder.decode(WeatherResponse.self, from: data)
        } catch let error as DecodingError {
            throw WeatherError.decodingError(error)
        } catch {
            throw WeatherError.networkError(error)
        }
    }
    
    func fetchGeocodingSuggestions(for query: String) async throws -> [City] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let isZipCode = query.allSatisfy({ $0.isNumber })
        let endpoint = isZipCode ? "zip?zip=" : "direct?q="
        let urlString = "\(baseURL)/geo/1.0/\(endpoint)\(encodedQuery)&limit=5&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if isZipCode {
            do {
                let zipResponse = try JSONDecoder().decode(ZipResponse.self, from: data)
                return [City(name: zipResponse.name, country: zipResponse.country, state: nil, lat: zipResponse.lat, lon: zipResponse.lon)]
            } catch {
                return []
            }
        } else {
            guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                throw WeatherError.invalidResponse
            }
            
            let cities = try JSONDecoder().decode([City].self, from: data)
            // api returns duplicates so i'm filtering them out
            let uniqueCities = Array(Set(cities))
            return uniqueCities.sorted { $0.name < $1.name }
        }
    }
}
