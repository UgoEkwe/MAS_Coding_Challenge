//
//  SearchOverlay.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import SwiftUI

struct SearchOverlay: View {
    @ObservedObject var viewModel: WeatherViewModel

    var body: some View {
        VStack {
            if !viewModel.suggestions.isEmpty {
                List(viewModel.suggestions) { city in
                    Button(action: {
                        Task {
                            hideKeyboard()
                            await viewModel.fetchWeather(for: city)
                            viewModel.suggestions = []
                            viewModel.query = ""
                        }
                    }) {
                        HStack {
                            Text(city.name)
                            Spacer()
                            VStack (spacing: 0) {
                                if let state = city.state {
                                    Text(state)
                                }
                                Text(city.country)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            Spacer()
        }
        .padding(.top, 50)
    }
}
