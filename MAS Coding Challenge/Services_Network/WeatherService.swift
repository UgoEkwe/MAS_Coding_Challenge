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

enum WeatherError: WeatherServiceError {
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
}

protocol WeatherServiceProtocol {
    func fetchWeather(for city: City) async throws -> WeatherResponse
    func fetchWeather(for location: CLLocation) async throws -> WeatherResponse
    func fetchGeocodingSuggestions(for query: String) async throws -> [City]
}

class WeatherService: WeatherServiceProtocol {
    private let apiKey: String
    private let baseURL = "https://api.openweathermap.org"
    
    init() {
        self.apiKey = KeyManager.shared.getAPIKey(for: "WeatherAPIKey") ?? ""
    }
    
    func fetchWeather(for city: City) async throws -> WeatherResponse {
        let urlString = "\(baseURL)/data/2.5/weather?lat=\(city.lat)&lon=\(city.lon)&appid=\(apiKey)&units=metric"
        return try await fetchWeather(from: urlString)
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
        let urlString = "\(baseURL)/geo/1.0/direct?q=\(encodedQuery)&limit=5&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                throw WeatherError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode([City].self, from: data)
        } catch let error as DecodingError {
            throw WeatherError.decodingError(error)
        } catch {
            throw WeatherError.networkError(error)
        }
    }
}
