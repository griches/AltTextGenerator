//
//  AltTextGeneratorApp.swift
//  AltTextGenerator
//
//  Created by Gary Riches on 01/07/2025.
//

import SwiftUI
import AppIntents

@main
struct AltTextGeneratorApp: App {
    init() {
        AltTextGeneratorShortcuts.updateAppShortcutParameters()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
