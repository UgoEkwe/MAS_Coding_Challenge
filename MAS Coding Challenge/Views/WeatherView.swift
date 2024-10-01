//
//  WeatherView.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import SwiftUI

struct WeatherView: View {
    @StateObject var viewModel: WeatherViewModel
    @AppStorage("selectedSystem") private var selectedSystem: String = "imperial"
    
    var body: some View {
        VStack {
            HStack {
                SearchBarView(searchTerm: $viewModel.query)
                Spacer()
                Button {
                    selectedSystem = selectedSystem == "imperial" ? "metric" : "imperial"
                } label: {
                    Text(selectedSystem == "imperial" ? "°F" : "°C")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.black)
                }
            }
            .padding()
            ScrollView (showsIndicators: false) {
                // would much rather have built a custom alert view for this and inject a description based on the error message
                if viewModel.errorMessage != nil {
                    Text("Sorry, we couldn't load the weather for that city. Please try again")
                        .foregroundColor(.red)
                        .padding()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                viewModel.errorMessage = nil
                            }
                        }
                }
                
                if let currentweather = viewModel.currentWeather {
                    WeatherCardView(weather: currentweather, system: selectedSystem, color: .black.opacity(0.9))
                        .foregroundStyle(Color.white)
                        .overlay (alignment: .topTrailing) {
                            Button {
                                Task {
                                    await viewModel.fetchWeatherForCurrentLocation()
                                }
                            } label : {
                                Image(systemName: "location")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundStyle(Color.blue)
                                    .padding([.top,.trailing], 10)
                            }
                        }
                }
                
                if let selectedWeather = viewModel.weather {
                    WeatherCardView(weather: selectedWeather, system: selectedSystem, color: Constants.darkBlack)
                        .foregroundStyle(Color.white)
                }
                
                if let lastWeather = viewModel.lastSearchWeather {
                    WeatherCardView(weather: lastWeather, system: selectedSystem, color: Constants.darkBlack.opacity(0.8))
                        .foregroundStyle(Color.white)
                }
                
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .overlay(SearchOverlay(viewModel: viewModel))
        .ignoresSafeArea(edges: .bottom)
    }
}
