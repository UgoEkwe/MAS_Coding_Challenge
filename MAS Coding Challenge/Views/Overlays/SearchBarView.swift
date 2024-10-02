//
//  SearchBarView.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchTerm: String
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.white)
                .frame(width: 22, height: 22)
                .padding(.leading, 4)
                .accessibility(hidden: true)
            ZStack(alignment: .leading) {
                Text("Search for a city or zip code")
                    .font(.system(size: 16))
                    .foregroundColor(!searchTerm.isEmpty ? Color.clear : Color.white.opacity(0.5))
                    .accessibility(hidden: true)
                TextField("", text: $searchTerm, onEditingChanged: { editing in
                }, onCommit: {
                    searchTerm = ""
                    hideKeyboard()
                })
                .submitLabel(.done)
                .foregroundStyle(Color.white)
                .font(.system(size: 16))
                .accessibilityLabel("Search for a city or zip code")
            }
            .padding(.vertical, 10)
        }
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Constants.systemGrey)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Search bar")
        .accessibilityHint("Enter a city name or zip code to search for weather")
    }
}
