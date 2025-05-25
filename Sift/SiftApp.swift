//
//  SiftApp.swift
//  Sift
//
//  Created by Ayodeji Osasona on 23/05/2025.
//

import SharingGRDB
import SwiftUI

@main
struct SiftApp: App {
    var feedManager: FeedManager?
    
    @AppStorage(AppStorageKey.hasCompletedOnboarding.rawValue) private var hasCompletedOnboarding:
        Bool = false
    @AppStorage(AppStorageKey.colorScheme.rawValue) private var rawPreferredColorScheme: String =
        PreferredColorScheme.system.rawValue

    init() {
        let appDatabase = try! AppDatabase.init()
        prepareDependencies {
            $0.defaultDatabase = appDatabase.getDatabase()
        }
        
        self.feedManager = FeedManager(db: appDatabase.getDatabase())
    }

    var body: some Scene {
        WindowGroup {
            if !hasCompletedOnboarding {
                WelcomeView()
                    .preferredColorScheme(
                        PreferredColorScheme.fromString(rawPreferredColorScheme).colorScheme
                    )
            } else {
                TabbedRootView()
                    .preferredColorScheme(
                        PreferredColorScheme.fromString(rawPreferredColorScheme).colorScheme
                    )
            }
        }
    }
}
