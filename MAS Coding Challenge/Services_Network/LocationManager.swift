//
//  LocationManager.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import Foundation
import CoreLocation

enum LocationError: Error {
    case permissionDenied
    
    var localizedDescription: String {
        switch self {
        case .permissionDenied:
            return "Location permission was denied. Please enable location services to use this feature."
        }
    }
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var userLocation: CLLocation?

    func requestLocationPermission(completion: @escaping (Bool) -> Void) {
        locationManager.requestWhenInUseAuthorization()
        let status = locationManager.authorizationStatus
        completion(status == .authorizedWhenInUse || status == .authorizedAlways)
    }

    func getUserLocation(completion: @escaping (CLLocation) -> Void) {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
           userLocation = location
        }
    }
}
