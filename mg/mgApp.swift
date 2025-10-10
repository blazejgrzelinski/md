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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(DataManager.shared.container)
    }
}
