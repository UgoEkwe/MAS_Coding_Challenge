//
//  SearchOverlay.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import SwiftUI
import CoreLocation

struct SearchOverlay: View {
    @EnvironmentObject private var viewModel: WeatherViewModel

    var body: some View {
        VStack {
            if !viewModel.suggestions.isEmpty {
                List(viewModel.suggestions) { city in
                    Button(action: {
                        Task {
                            hideKeyboard()
                            await viewModel.fetchWeatherForLocation(CLLocation(latitude: city.lat, longitude: city.lon))
                            viewModel.suggestions = []
                            viewModel.query = ""
                        }
                    }) {
                        HStack {
                            Text(city.name)
                            Spacer()
                            VStack(spacing: 0) {
                                if let state = city.state {
                                    Text(state)
                                }
                                Text(city.country)
                            }
                        }
                    }
                    .accessibilityLabel("\(city.name), \(city.state ?? ""), \(city.country)")
                    .accessibilityHint("Double tap to select this location")
                }
                .listStyle(PlainListStyle())
            }
            Spacer()
        }
        .padding(.top, 65)
        .accessibilityLabel("Search results")
    }
}
