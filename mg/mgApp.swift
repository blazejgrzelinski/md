//
//  mgApp.swift
//  mg
//
//  Created by Blazej Grzelinski on 07/10/2025.
//

import SwiftUI
import SwiftData

@main
struct mgApp: App {
    init() {
        // Suppress system warnings
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        // Suppress keyboard constraint warnings
        if #available(iOS 13.0, *) {
            UserDefaults.standard.set(false, forKey: "_UIKeyboardLayoutConstraintLogUnsatisfiable")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(DataManager.shared.container)
    }
}
