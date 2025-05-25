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

    @State private var refreshTask: Task<Void, Never>? = nil

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
                    .environmentObject(feedManager!)
            } else {
                TabbedRootView()
                    .preferredColorScheme(
                        PreferredColorScheme.fromString(rawPreferredColorScheme).colorScheme
                    )
                    .environmentObject(feedManager!)
                    .task {
                        refreshTask = Task.detached {
                            while true {
                                try? await Task.sleep(nanoseconds: 60 * 60 * 1_000_000_000)  // 1 hour
                                await feedManager?.refreshAll()
                            }
                        }
                    }
            }
        }
    }
}
