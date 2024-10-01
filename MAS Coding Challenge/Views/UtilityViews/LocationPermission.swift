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
            
            Text("Location Access")
                .font(.title)
                .fontWeight(.bold)
            
            Text("We need your location to provide accurate weather information. If you decline, we'll show weather for 5 major cities.")
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .onAppear{locationManager.requestLocationPermission()}
    }
}
