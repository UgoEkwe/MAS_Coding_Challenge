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
    case notDetermined
    case timeout
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .permissionDenied:
            return "Location permission was denied. Please enable location services to use this feature."
        case .notDetermined:
            return "Location permission has not been determined yet."
        case .timeout:
            return "Timed out while trying to get the current location."
        case .unknown:
            return "An unknown error occurred while trying to get the location."
        }
    }
}


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus
    
    override init() {
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func getCurrentLocation() async throws -> CLLocation {
        if authorizationStatus == .notDetermined {
            requestLocationPermission()
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            switch authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.requestLocation()
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    if let location = self.userLocation {
                        continuation.resume(returning: location)
                    } else {
                        continuation.resume(throwing: LocationError.timeout)
                    }
                }
            case .denied, .restricted:
                continuation.resume(throwing: LocationError.permissionDenied)
            case .notDetermined:
                continuation.resume(throwing: LocationError.notDetermined)
            @unknown default:
                continuation.resume(throwing: LocationError.unknown)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}
