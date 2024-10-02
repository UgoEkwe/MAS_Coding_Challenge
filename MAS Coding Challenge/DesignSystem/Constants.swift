//
//  Constants.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import Foundation
import SwiftUI

struct Constants {
    static let currentWeatherBackgrounds: [Color] = [
        skyBlue,
        pastelPeach,
        pastelPurple,
        pastelRed,
        pastelGreen
    ]
    static let magicGrey = Color(hex: "#303030") // dark grey, used for main search card
    static let systemGrey = Color(hex: "#8E8E93") // neutral element, used for search bar
    static let darkBlack = Color(red: 0.11, green: 0.11, blue: 0.12)
    
    // pastel colors for recent search cards
    static let skyBlue: Color = Color.blue.opacity(0.1)
    static let pastelPeach: Color = Color(red: 1.0, green: 0.85, blue: 0.73).opacity(0.8)
    static let pastelPurple: Color = Color(red: 0.87, green: 0.82, blue: 0.91).opacity(0.8)
    static let pastelRed: Color = Color(red: 1.0, green: 0.75, blue: 0.75).opacity(0.8)
    static let pastelGreen: Color = Color(red: 0.79, green: 0.94, blue: 0.79).opacity(0.8)
    
    static let majorCities: [City] = [
        City(name: "New York", country: "US", state: "NY", lat: 40.7128, lon: -74.0060),
        City(name: "London", country: "GB", state: "", lat: 51.5074, lon: -0.1278),
        City(name: "Tokyo", country: "JP", state: "", lat: 35.6762, lon: 139.6503),
        City(name: "Sydney", country: "AU", state: "NSW", lat: -33.8688, lon: 151.2093),
        City(name: "Rio de Janeiro", country: "BR", state: "", lat: -22.9068, lon: -43.1729)
    ]
}
