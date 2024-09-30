//
//  KeyManager.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 9/30/24.
//

import Foundation

class KeyManager {
    static let shared = KeyManager()
    
    private var apiKeys: [String: String]?
    
    private init() {
        loadAPIKeys()
    }
    
    private func loadAPIKeys() {
        if let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist"),
           let keys = NSDictionary(contentsOfFile: path) as? [String: String] {
            apiKeys = keys
        }
    }
    
    func getAPIKey(for key: String) -> String? {
        return apiKeys?[key]
    }
}
