//
//  WeatherModel.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import Foundation

/*
 I structured these models to closely match the API responses from OpenWeatherMap. The models include City, ZipResponse, WeatherResponse, and nested structures like Coord, Weather, Main, Wind, Rain, Clouds, and Sys. Each model is Codable to facilitate easy JSON parsing. I would have liked to use more of these properties like sunset and sunrise or gust, but couldn't find the space for them in the design.
*/

//MARK: City model bazsed on API response
struct City: Identifiable, Decodable, Hashable {
    var id: String { "\(name),\(country)" }
    let name: String
    let country: String
    let state: String?
    let lat: Double
    let lon: Double
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: City, rhs: City) -> Bool {
        return lhs.id == rhs.id
    }
}

//MARK: model for numeric queries
struct ZipResponse: Decodable {
    let zip: String
    let name: String
    let lat: Double
    let lon: Double
    let country: String
}

// MARK: - WeatherResponse
struct WeatherResponse: Codable {
    let coord: Coord
    let weather: [Weather]
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind
    let rain: Rain?
    let clouds: Clouds
    let dt: Int
    let sys: Sys
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int
}

// MARK: - Coord
struct Coord: Codable {
    let lon: Double
    let lat: Double
}

// MARK: - Weather
struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

// MARK: - Main
struct Main: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    let seaLevel: Int?
    let grndLevel: Int?
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
    }
}

// MARK: - Wind
struct Wind: Codable {
    let speed: Double
    let deg: Int
    let gust: Double?
}

// MARK: - Rain
struct Rain: Codable {
    let oneHour: Double
    
    enum CodingKeys: String, CodingKey {
        case oneHour = "1h"
    }
}

// MARK: - Clouds
struct Clouds: Codable {
    let all: Int
}

// MARK: - Sys
struct Sys: Codable {
    let type: Int
    let id: Int
    let country: String
    let sunrise: Int
    let sunset: Int
}
