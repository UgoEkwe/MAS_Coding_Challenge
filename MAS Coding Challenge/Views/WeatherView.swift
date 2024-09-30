//
//  WeatherView.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import SwiftUI

struct WeatherView: View {
    @StateObject var viewModel: WeatherViewModel
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Spacer()
                Button {
                } label: {
                    Text("°F")
                        .foregroundStyle(Color.white)
                }
            }
            .padding()
            Spacer()
            if let weather = viewModel.weather {
                VStack(alignment: .leading, spacing: 5) {
                    Text(weather.name)
                    Text("Temperature: \(weather.main.temp, specifier: "%.1f")°C")
                    
                }
                Text("Conditions: \(weather.weather.first?.description ?? "")")
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            Spacer()
        }
        .overlay{
            VStack {
                TextField("Search for a city", text: $viewModel.query)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !viewModel.suggestions.isEmpty {
                    List(viewModel.suggestions) { city in
                        Button(action: {
                            Task {
                                hideKeyboard()
                                await viewModel.fetchWeather(for: city)
                            }
                        }) {
                            HStack {
                                Text(city.name)
                                Spacer()
                                Text(city.country)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .padding()
    }
}
