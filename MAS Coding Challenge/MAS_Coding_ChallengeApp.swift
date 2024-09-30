//
//  MAS_Coding_ChallengeApp.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import SwiftUI

@main
struct WeatherApp: App {
    private let coordinator = WeatherCoordinator()
    @AppStorage ("selectedSystem") private var selectedSystem: String = "imperial"

    var body: some Scene {
        WindowGroup {
            coordinator.start()
        }
    }
}
