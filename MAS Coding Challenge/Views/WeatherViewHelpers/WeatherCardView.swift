//
//  CurrentWeatherView.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import SwiftUI

struct WeatherCardView: View {
    let weather: WeatherResponse
    let system: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
    }
}
