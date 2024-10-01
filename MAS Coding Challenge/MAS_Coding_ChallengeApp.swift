//
//  MAS_Coding_ChallengeApp.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import SwiftUI

@main
struct WeatherApp: App {
    @StateObject var coordinator = WeatherCoordinator()

    var body: some Scene {
        WindowGroup {
            coordinator.start()
        }
    }
}
