//
//  LocationPermission.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import SwiftUI

struct LocationPermissionView: View {
    let locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.circle")
                .font(.system(size: 100))
                .foregroundColor(.blue)
                .accessibility(hidden: true)
            
            Text("Location Access")
                .font(.title)
                .fontWeight(.bold)
            
            Text("We need your location to provide accurate weather information. If you decline, we'll show weather for 5 major cities.")
                .multilineTextAlignment(.center)
                .padding()
            
            Button {
                locationManager.requestLocationPermission()
            } label: {
                Text("Share Location")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule(style: .circular))
            }
            .accessibilityHint("Double tap to grant location access")
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Location Access Request")
    }
}
