//
//  CurrentWeatherView.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import SwiftUI

/*
 The WeatherCardView is a reusable component for displaying weather information--it encapsulates the layout and styling of individual weather cards.
 It takes in a WeatherResponse object and displays the relevant information.
 The use of AsyncImage for weather icons ensures we're not blocking the main thread while loading images, ensuring smooth and responsive UI.
*/
struct WeatherCardView: View {
    let weather: WeatherResponse
    let system: String
    let color: Color
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            Text(weather.name)
                .font(.largeTitle)
            HStack {
                Text(String(format: "%.1f°", weather.main.temp.convertTemperature(system: system)))
                    .font(.system(size: 60))
                Spacer()
                AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(weather.weather.first?.icon ?? "")@2x.png")) { image in
                    image.resizable()
                        .shadow(color: .white, radius: 3)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 80, height: 80)
                .accessibility(hidden: true)
            }
            Text(weather.weather.first?.description.capitalized ?? "")
                .font(.title2)
            HStack {
                Label("Feels like \(String(format: "%.1f°", weather.main.feelsLike.convertTemperature(system: system)))", systemImage: "thermometer")
                Spacer()
                Label("\(weather.main.humidity)%", systemImage: "humidity")
            }
            .font(.subheadline)
        }
        .padding()
        .background(color)
        .cornerRadius(10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Weather for \(weather.name)")
        .accessibilityValue("Temperature: \(String(format: "%.1f°", weather.main.temp.convertTemperature(system: system))), \(weather.weather.first?.description.capitalized ?? ""). Feels like \(String(format: "%.1f°", weather.main.feelsLike.convertTemperature(system: system))). Humidity: \(weather.main.humidity)%")
    }
}
