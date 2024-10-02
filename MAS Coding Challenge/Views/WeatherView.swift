//
//  WeatherView.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import SwiftUI

/*
 WeatherView is the main view--I designed it to display both the current weather (if available) and recent searches.
 I've used a ScrollView to allow for multiple weather cards, and I've implemented a loading state with skeleton views for a better user experience.
 The search bar and unit toggle are placed at the top for easy access. I've also added an error handling mechanism with a custom alert view.
 When placing a search, the user must click a suggestion from the presented list in the SearchOverlay.
 I designed it like this to ensure the user doesn't add a city by mistake.
 Each View and child-view has VoiceOver capability.
*/
struct WeatherView: View {
    @EnvironmentObject private var viewModel: WeatherViewModel
    let colors: [Color] = Constants.currentWeatherBackgrounds
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    SearchBarView(searchTerm: $viewModel.query)
                    Spacer()
                    Button {
                        viewModel.selectedSystem = viewModel.selectedSystem == "imperial" ? "metric" : "imperial"
                    } label: {
                        Text(viewModel.selectedSystem == "imperial" ? "°F" : "°C")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(UIColor.systemIndigo))
                    }
                }
            }
            .padding()
            
            ScrollView(showsIndicators: false) {
                if let currentWeather = viewModel.currentWeather {
                    if viewModel.isLoading {
                        WeatherCardSkeleton(color: Constants.darkBlack)
                            .foregroundColor(Color.white)
                    } else {
                        WeatherCardView(weather: currentWeather, system: viewModel.selectedSystem, color: Constants.darkBlack)
                            .foregroundColor(Color.white)
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    Task {
                                        await viewModel.fetchWeatherForCurrentLocation()
                                    }
                                } label: {
                                    Image(systemName: "location")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(Color.blue)
                                        .padding([.top, .trailing], 10)
                                }
                            }
                    }
                }
                
                ForEach(Array(viewModel.recentList.enumerated()), id: \.offset) { index, forecast in
                    if viewModel.isLoading {
                        WeatherCardSkeleton(color: colors[index % colors.count])
                    } else {
                        WeatherCardView(weather: forecast, system: viewModel.selectedSystem, color: colors[index % colors.count])
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .overlay(SearchOverlay())
        .onChange(of: viewModel.errorMessage, perform: { new in
            if new != nil {
                showAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    viewModel.errorMessage = nil
                    showAlert = false
                }
            }
        })
        .overlay(
            UIKitAlertView(
                isPresented: $showAlert,
                title: "Sorry",
                message: "We couldn't load the weather for that city. Please try again."
            )
            .allowsHitTesting(false)
        )
        .ignoresSafeArea(edges: .bottom)
    }
}

