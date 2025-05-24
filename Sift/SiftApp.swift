//
//  SiftApp.swift
//  Sift
//
//  Created by Ayodeji Osasona on 23/05/2025.
//

import SwiftUI
import SharingGRDB

@main
struct SiftApp: App {
    @AppStorage(AppStorageKey.hasCompletedOnboarding.rawValue) private var hasCompletedOnboarding: Bool = false
    @AppStorage(AppStorageKey.colorScheme.rawValue) private var rawPreferredColorScheme: String = PreferredColorScheme.system.rawValue
    
    init() {
        try! prepareDependencies {
            $0.defaultDatabase = try AppDatabase.init().getDatabase()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if !hasCompletedOnboarding {
                WelcomeView()
                    .preferredColorScheme(PreferredColorScheme.fromString(rawPreferredColorScheme).colorScheme)
            } else {
                TabbedRootView()
                    .preferredColorScheme(PreferredColorScheme.fromString(rawPreferredColorScheme).colorScheme)
            }
        }
    }
}
