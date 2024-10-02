//
//  UIKitAlertView.swift
//  MAS Coding Challenge
//
//  Created by Ugonna Oparaochaekwe on 10/1/24.
//

import SwiftUI
import UIKit

/*
 The UIKitAlertView is a bridge between SwiftUI and UIKit
 This approach allows us to present a UIKit alert within our SwiftUI view hierarchy, giving us more control over the alert's appearance and behavior.
 I would have liked to handle more scenerios but decided to display only one alert for time.
*/
struct UIKitAlertView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                isPresented = false
            })
            uiViewController.present(alert, animated: true)
        }
    }
}
