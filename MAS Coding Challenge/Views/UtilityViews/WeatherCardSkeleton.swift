//
//  WeatherCardSkeleton.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 10/1/24.
//

import SwiftUI

struct WeatherCardSkeleton: View {
    let color: Color
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 150, height: 30)
            
            HStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 60)
                Spacer()
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
            }
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 200, height: 20)
            
            HStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 20)
                Spacer()
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 20)
            }
        }
        .padding()
        .background(color)
        .cornerRadius(10)
    }
}
