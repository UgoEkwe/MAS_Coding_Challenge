//
//  Extensions.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import Foundation
import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

extension Double {
    func convertTemperature(system: String) -> Double {
        return system == "imperial" ? Double(self) * 9/5 + 32 : Double(self)
    }
}
