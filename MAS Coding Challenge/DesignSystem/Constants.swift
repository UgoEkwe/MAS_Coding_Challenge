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
    
    // pastel colors for recent search cards
    static let skyBlue: Color = Color.blue.opacity(0.1)
    static let pastelPeach: Color = Color(red: 1.0, green: 0.85, blue: 0.73).opacity(0.8)
    static let pastelPurple: Color = Color(red: 0.87, green: 0.82, blue: 0.91).opacity(0.8)
    static let pastelRed: Color = Color(red: 1.0, green: 0.75, blue: 0.75).opacity(0.8)
    static let pastelGreen: Color = Color(red: 0.79, green: 0.94, blue: 0.79).opacity(0.8)
}

// extension to initialize Color from hex code
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
