//
//  RecentForecastsVeiw.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import SwiftUI

struct RecentForecastsView: View {
    let forecasts: [WeatherResponse]
    let system: String
    let colors: [Color] = Constants.currentWeatherBackgrounds

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 15) {
                    ForEach(Array(forecasts.enumerated()), id: \.offset) { index, forecast in
                        CurrentWeatherView(weather: forecast,system: system,color: colors[index % colors.count])
                    }
                }
            }
        }
        .padding()
    }
}
